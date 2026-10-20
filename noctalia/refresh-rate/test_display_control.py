import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("display_control", Path(__file__).with_name("display-control.py"))
control = importlib.util.module_from_spec(spec)
spec.loader.exec_module(control)


def outputs(rate=144003):
    return {"eDP-1": {"name": "eDP-1", "make": "BOE", "model": "Panel", "current_mode": 0,
        "modes": [{"width": 1920, "height": 1080, "refresh_rate": rate},
                  {"width": 1920, "height": 1080, "refresh_rate": 60001},
                  {"width": 1280, "height": 720, "refresh_rate": 120000}]}}


class DisplayControlTest(unittest.TestCase):
    def test_only_same_resolution_rates_are_offered(self):
        self.assertEqual(control.active_modes(outputs())[0]["rates"], [60001, 144003])

    @patch.object(control, "query", return_value=outputs())
    @patch.object(control.subprocess, "run")
    def test_unavailable_rate_never_changes_display(self, run, query):
        with self.assertRaises(ValueError):
            control.set_rate("eDP-1", 120000)
        run.assert_not_called()

    @patch.object(control, "query", return_value=outputs())
    @patch.object(control.subprocess, "run")
    def test_disconnected_display_never_changes_display(self, run, query):
        with self.assertRaises(ValueError):
            control.set_rate("HDMI-A-1", 60001)
        run.assert_not_called()

    @patch.object(control, "query", side_effect=[outputs(), outputs(60001)])
    @patch.object(control.subprocess, "run")
    def test_fractional_rate_preserves_resolution_and_is_verified(self, run, query):
        control.set_rate("eDP-1", 60001)
        self.assertEqual(run.call_args.args[0], ["niri", "msg", "output", "eDP-1", "mode", "1920x1080@60.001"])

    @patch.object(control, "query", return_value=outputs())
    @patch.object(control.subprocess, "run")
    def test_unconfirmed_change_reports_failure(self, run, query):
        with self.assertRaises(RuntimeError):
            control.set_rate("eDP-1", 60001)


if __name__ == "__main__":
    unittest.main()
