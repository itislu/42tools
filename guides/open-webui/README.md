# Open WebUI

Open WebUI is a self-hosted web interface for various LLMs.
It uses the APIs of the model providers which is considerably **cheaper** than subscribing to the subscriptions. You pay only for your usage.

Another benefit is that you can use **multiple models** from different providers **in one place** and are not bound to one if you don't want to pay for multiple subscriptions at the same time.

https://github.com/open-webui/open-webui

## Setup

I wrote a shell function which starts the Open WebUI container with just one command.

Copy-paste this into your terminal to add the `open-webui` function to your shell:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/itislu/42tools/refs/heads/main/guides/open-webui/install.sh)
```

### Usage

```
open-webui [stop]
```

Open WebUI is then running on `http://localhost:3000`.

---

### OpenAI ChatGPT support

1. Get your OpenAI API key from here: https://platform.openai.com/api-keys

2. Add your API key [here](http://localhost:3000/admin/settings): `Connections > API Key > Validate the key (circular arrows icon)`

3. In order for the premium models to show up, you need to add some credit balance to your OpenAI account here: https://platform.openai.com/settings/organization/billing/overview

4. Refresh the page

### Anthropic Claude support

1. Install the Anthropic function in the WebUI

   - **With Open WebUI account:**<br>
     https://openwebui.com/f/justinrahb/anthropic

   - **Without Open Webui account:**<br>
     In order to conveniently install the function you will have to create an account on openwebui.com.<br>
     I think it is worth it because it gives you access to a marketplace of functions and more to customize the UI and extend its functionality - kind of like extensions for VS Code.<br>
     If you don't want to do that, you can download the Anthropic function here and import it manually:
     ```bash
     curl -LO https://raw.githubusercontent.com/itislu/42tools/refs/heads/main/guides/open-webui/Anthropic-function.json
     ```

2. Get your Anthropic API key from here and then click on Save: https://console.anthropic.com/settings/keys

3. Add your API key [here](http://localhost:3000/workspace/functions): `Anthropic (settings icon) > Default`

4. Enable the Anthropic function (toggle on the right)

5. In order to use any models from Anthropic, you need to add some credit balance to your Anthropic account here: https://console.anthropic.com/settings/plans

6. Refresh the page
