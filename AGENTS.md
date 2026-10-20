# Personal machine workflows

When the user says **"Movie on my TV"** (or equivalent), follow
[the saved movie workflow](movie-server/WORKFLOW.md) to start the existing
ReadyMedia server. When they finish watching, follow its cleanup steps.

Preserve display refresh rate, brightness, audio output, and the selected power
profile unless the user explicitly asks for changes. Do not interrupt an active
movie to apply configuration updates. Keep the movie server stopped after cleanup.

When the user requests publication of these configs, keep `main` and `master`
at the same commit, preserving changes from both and avoiding force pushes.
