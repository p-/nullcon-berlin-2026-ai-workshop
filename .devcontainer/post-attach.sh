#!/bin/bash
set -e

# VS Code's Python extension sends Ctrl+C before activating the venv in this
# terminal. Ignore it so setup can finish; activation runs afterwards.
trap '' INT

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env template..."
    # Build the template in a temp file and move it into place at the end, so
    # an interrupted run doesn't leave a partial .env that blocks later runs.
    ENV_TMP=$(mktemp)
    trap 'rm -f "$ENV_TMP"' EXIT

    # Test whether api.githubcopilot.com works with the GITHUB_TOKEN
    # provided by the codespace. If so, configure .env to use that token.
    USE_GITHUB_TOKEN="false"
    if [ ! -v AI_API_TOKEN ] && [ -v CODESPACES ] && [ -v GITHUB_TOKEN ]; then
        if curl --fail --silent --show-error --max-time 10 https://api.githubcopilot.com/models -H "Authorization: Bearer $GITHUB_TOKEN" > /dev/null; then
            USE_GITHUB_TOKEN="true"
            echo 'AI_API_TOKEN=${GITHUB_TOKEN}' >> "$ENV_TMP"
            if [ ! -v GH_TOKEN ]; then
                echo 'GH_TOKEN=${GITHUB_TOKEN}' >> "$ENV_TMP"
            fi
            echo >> "$ENV_TMP"
        fi
    fi

    # If running in Codespaces, check for necessary secrets and print error if missing
    if [ -v CODESPACES ]; then
        if [[ "$USE_GITHUB_TOKEN" == "false" ]]; then
           if [ ! -v AI_API_TOKEN ]; then
               echo "⚠️ Running in Codespaces - please add AI_API_TOKEN to your Codespaces secrets"
           fi
           if [ ! -v GH_TOKEN ]; then
               echo "⚠️ Running in Codespaces - please add GH_TOKEN to your Codespaces secrets"
           fi
        fi
    fi

    echo "# Uncomment the endpoint that you want to use:" >> "$ENV_TMP"
    echo "#AI_API_ENDPOINT=https://models.github.ai/inference" >> "$ENV_TMP"
    echo "#AI_API_ENDPOINT=https://api.openai.com/v1" >> "$ENV_TMP"

    # Use api.githubcopilot.com by default if USE_GITHUB_TOKEN is true.
    if [[ "$USE_GITHUB_TOKEN" == "true" ]]; then
        echo "AI_API_ENDPOINT=https://api.githubcopilot.com" >> "$ENV_TMP"
    else
        echo "#AI_API_ENDPOINT=https://api.githubcopilot.com" >> "$ENV_TMP"
    fi

    echo >> "$ENV_TMP"
    echo "# Uncomment to set the model temperature" >> "$ENV_TMP"
    echo "#MODEL_TEMP=1.0" >> "$ENV_TMP"
    echo >> "$ENV_TMP"
    echo "# Optional data storage directories. By default, ~/.local is used." >> "$ENV_TMP"
    echo "MEMCACHE_STATE_DIR=/workspaces/nullcon-berlin-2026-ai-workshop/data" >> "$ENV_TMP"
    echo "CODEQL_DBS_BASE_PATH=/workspaces/nullcon-berlin-2026-ai-workshop/data" >> "$ENV_TMP"
    echo "DATA_DIR=/workspaces/nullcon-berlin-2026-ai-workshop/data" >> "$ENV_TMP"
    echo "LOG_DIR=/workspaces/nullcon-berlin-2026-ai-workshop/logs" >> "$ENV_TMP"
    mv "$ENV_TMP" .env

    code .env || echo "ℹ️ Unable to open .env in VS Code. Please open and review the .env file manually."
    code README.md
    echo "⚠️  Defaults can be changed by editing the auto-generated .env file."
fi

echo "💡 Remember to activate the virtual environment: source .venv/bin/activate"
