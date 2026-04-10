```powershell
wsl --install -d Ubuntu-22.04
```

Den Benutzer festelegen, mit passwort. Dann: 

```bash
cd ~
pwd
```

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

```bash
node -v
npm -v
```

```bash
sudo apt-get install zstd
```



curl -o setup_ultimate_v3.sh https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/Manus_auto/complete_setup_v3/setup_ultimate_v3.sh | bash


chmod +x setup_ultimate_v3.sh
./setup_ultimate_v3.sh


curl -o ./scripts/hybrid_setup.sh https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/Manus_auto/complete_setup_v3/scripts/hybrid_setup.sh | bash

