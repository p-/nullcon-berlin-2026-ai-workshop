# Development

### Codespaces prebuilds (repository maintainers)

The [dev container configuration](.devcontainer/devcontainer.json) installs the
Python virtual environment and workshop dependencies in `updateContentCommand`,
so they are included in Codespaces prebuild snapshots. The same setup runs when
creating a Codespace without a prebuild and can run again when workspace content
changes. VS Code uses the workspace's `.venv` interpreter.

To enable prebuilds on GitHub (requires repository admin access):

1. Open **Settings -> Codespaces -> Set up prebuild**.
2. Select the workshop branch and `.devcontainer/devcontainer.json`.
3. Choose **Every push** so changes to Python dependencies and setup scripts are
   included, and select the regions workshop participants will use.
4. Click **Create** and wait for the generated GitHub Actions prebuild workflow
   to succeed. New Codespaces using that branch, configuration, and region
   should show **Prebuild ready**.

No personal API tokens are needed to build the prebuild. The `.env` file and
credential checks remain in `postAttachCommand`, which runs when a participant
connects, after their Codespaces secrets are available. Do not add personal
tokens to prebuild setup.

Prebuilds consume GitHub Actions minutes and storage. See GitHub's
[prebuild configuration documentation](https://docs.github.com/en/codespaces/prebuilding-your-codespaces/configuring-prebuilds)
for trigger, region, and billing details.
