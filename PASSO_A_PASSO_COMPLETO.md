# 🎯 PASSO A PASSO EXATO - GitHub Actions Deploy

## ✅ PRÉ-REQUISITOS (Faça Primeiro):

### 1. Instalar Git
- [X] Baixe: https://git-scm.com/download/win
- [ ] Execute o instalador
- [ ] Clique "Next" em tudo
- [ ] Reinicie VS Code

### 2. Criar Conta GitHub (se não tiver)
- [ ] Acesse: https://github.com
- [ ] Clique "Sign up"
- [ ] Escolha username, email, senha
- [ ] Verifique email

---

## 🚀 PARTE 1: CONFIGURAR GIT (5 minutos)

### Passo 1.1: Configure seu nome e email

Abra o terminal do VS Code e execute:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### Passo 1.2: Verifique a configuração

```bash
git config --global --list
```

---

## 📦 PARTE 2: CRIAR REPOSITÓRIO NO GITHUB (10 minutos)

### Passo 2.1: Criar novo repositório

1. Acesse: https://github.com/new
2. Preencha:
   - **Repository name**: `app-financas`
   - **Description**: "App de controle financeiro pessoal"
   - **Visibility**: 🔒 Private (ou ✅ Public para mais minutos grátis)
3. ❌ **NÃO** marque "Add a README"
4. ❌ **NÃO** marque "Add .gitignore"
5. Clique **"Create repository"**

### Passo 2.2: Copie a URL do repositório

Você verá algo como:
```
https://github.com/SEU-USUARIO/app-financas.git
```

**COPIE ESSA URL!** Você vai precisar dela.

---

## 💻 PARTE 3: INICIALIZAR GIT NO PROJETO (5 minutos)

### Passo 3.1: Abra o terminal no VS Code

Certifique-se de estar na pasta do projeto:
```
C:\Users\Bruno - Hygicare\Desktop\App_Finanças
```

### Passo 3.2: Inicialize o Git

```bash
git init
```

✅ Você verá: "Initialized empty Git repository"

### Passo 3.3: Adicione todos os arquivos

```bash
git add .
```

⏳ Aguarde alguns segundos...

### Passo 3.4: Faça o primeiro commit

```bash
git commit -m "Projeto completo de finanças com Flutter"
```

✅ Você verá: "X files changed, Y insertions(+)"

### Passo 3.5: Renomeie branch para main

```bash
git branch -M main
```

### Passo 3.6: Conecte ao GitHub

**SUBSTITUA** `SEU-USUARIO` pela sua URL copiada no Passo 2.2:

```bash
git remote add origin https://github.com/SEU-USUARIO/app-financas.git
```

### Passo 3.7: Envie para o GitHub

```bash
git push -u origin main
```

🔑 Vai pedir login:
- **Username**: seu username do GitHub
- **Password**: **NÃO é sua senha!** É um "Personal Access Token"

---

## 🔑 PARTE 4: CRIAR PERSONAL ACCESS TOKEN (5 minutos)

### Passo 4.1: Gerar Token

1. Acesse: https://github.com/settings/tokens
2. Clique **"Generate new token"** → **"Classic"**
3. Preencha:
   - **Note**: "VS Code - App Finanças"
   - **Expiration**: 90 days
   - **Scopes**: ✅ Marque **"repo"** (todos os subitens)
4. Clique **"Generate token"**

### Passo 4.2: Copie o Token

⚠️ **IMPORTANTE**: Copie o token AGORA! Você não verá novamente!

Exemplo:
```
ghp_AbCdEfGhIjKlMnOpQrStUvWxYz1234567890
```

### Passo 4.3: Use o Token como Senha

Quando o Git pedir password, cole o TOKEN (não sua senha).

```bash
# Se der erro, tente novamente:
git push -u origin main
```

✅ Sucesso! Código está no GitHub!

---

## 🍎 PARTE 5: CONFIGURAR SECRETS PARA iOS (20 minutos)

### ⚠️ IMPORTANTE: Esta parte requer um Mac!

Se você **NÃO tem Mac agora**, pule para a **PARTE 6** (Android).

### No Mac, faça:

#### Passo 5.1: Criar Certificate Signing Request

1. Abra **"Keychain Access"**
2. Menu: Keychain Access → Certificate Assistant → Request a Certificate...
3. Preencha e salve: `CertificateSigningRequest.certSigningRequest`

#### Passo 5.2: Criar Distribution Certificate

1. Acesse: https://developer.apple.com/account/resources/certificates
2. Clique **"+"** → **"Apple Distribution"**
3. Upload do CSR
4. Download: `distribution.cer`
5. Duplo clique para instalar

#### Passo 5.3: Exportar P12

1. No Keychain, encontre: "Apple Distribution: Seu Nome"
2. Botão direito → Export
3. Salve como: `Certificates.p12`
4. Defina senha forte (guarde!)

#### Passo 5.4: Criar Provisioning Profile

1. Acesse: https://developer.apple.com/account/resources/identifiers
2. Registre App ID: `com.seuNome.minhasFinancas`
3. Acesse: https://developer.apple.com/account/resources/profiles
4. Crie perfil App Store
5. Download: `profile.mobileprovision`

#### Passo 5.5: Converter para Base64

No Terminal do Mac:

```bash
base64 -i Certificates.p12 -o cert.txt
base64 -i profile.mobileprovision -o profile.txt
```

#### Passo 5.6: Criar App-Specific Password

1. Acesse: https://appleid.apple.com
2. Sign-In and Security → App-Specific Passwords
3. Generate → "GitHub Actions"
4. Guarde a senha

#### Passo 5.7: Adicionar Secrets no GitHub

1. Acesse: `https://github.com/SEU-USUARIO/app-financas/settings/secrets/actions`
2. Clique **"New repository secret"** para cada:

| Nome | Valor |
|------|-------|
| `APPLE_CERTIFICATE_BASE64` | Conteúdo de `cert.txt` |
| `APPLE_CERTIFICATE_PASSWORD` | Senha do P12 |
| `PROVISIONING_PROFILE_BASE64` | Conteúdo de `profile.txt` |
| `APPLE_ID` | Seu email Apple ID |
| `APPLE_APP_SPECIFIC_PASSWORD` | Senha gerada |
| `APPLE_TEAM_ID` | Seu Team ID (em developer.apple.com) |

---

## 🤖 PARTE 6: BUILD ANDROID (5 minutos) - FUNCIONA SEM MAC!

### Passo 6.1: Verificar que o workflow está no repositório

Os arquivos já estão criados:
- `.github/workflows/android-build.yml` ✅
- `.github/workflows/ios-build.yml` ✅

### Passo 6.2: Fazer push (se ainda não fez)

```bash
git add .
git commit -m "Workflows do GitHub Actions"
git push
```

### Passo 6.3: Executar o Build Android Manualmente

1. Acesse: `https://github.com/SEU-USUARIO/app-financas/actions`
2. Clique em **"Build Android"** (lado esquerdo)
3. Clique em **"Run workflow"** (botão azul à direita)
4. Clique **"Run workflow"** (confirmação)

⏳ **Aguarde 10-15 minutos...**

### Passo 6.4: Baixar o APK

1. Quando terminar (✅ verde), clique no workflow executado
2. Role até **"Artifacts"**
3. Clique em **"android-apk-release"**
4. Download do ZIP
5. Extraia: `app-release.apk`

🎉 **PRONTO! Você tem o APK!**

---

## 📱 PARTE 7: INSTALAR NO CELULAR ANDROID (3 minutos)

### Passo 7.1: Transferir APK

Escolha um método:
- WhatsApp (envie para você mesmo)
- Google Drive
- Cabo USB
- Email

### Passo 7.2: Instalar

No Android:
1. Abra o APK
2. Toque "Instalar"
3. Se pedir, ative "Fontes desconhecidas" nas configurações
4. Instale novamente

✅ **APP INSTALADO!**

---

## 🍎 PARTE 8: BUILD iOS (SE TIVER CONFIGURADO) (5 minutos)

### Passo 8.1: Criar Tag de Versão

```bash
git tag v1.0.0
git push origin v1.0.0
```

Isso dispara automaticamente o workflow iOS!

### Passo 8.2: Acompanhar Build

1. Acesse: `https://github.com/SEU-USUARIO/app-financas/actions`
2. Veja o workflow **"Build e Upload para TestFlight"** rodando

⏳ **Aguarde 15-25 minutos...**

### Passo 8.3: Verificar no App Store Connect

1. Acesse: https://appstoreconnect.apple.com
2. Vá em seu app → TestFlight
3. O build aparecerá em "Processing" (aguarde mais 5-30 min)
4. Quando ficar "Ready to Submit", adicione testadores!

---

## ✅ CHECKLIST FINAL

### Setup Inicial (Uma vez):
- [ ] Git instalado
- [ ] Conta GitHub criada
- [ ] Repositório criado
- [ ] Código enviado para GitHub
- [ ] Personal Access Token criado
- [ ] Workflows configurados

### Build Android:
- [ ] Workflow executado
- [ ] APK baixado
- [ ] APK instalado no celular
- [ ] App funcionando!

### Build iOS (Opcional):
- [ ] Conta Apple Developer ativa
- [ ] Certificados criados
- [ ] Secrets configurados no GitHub
- [ ] Tag criada
- [ ] Build enviado para TestFlight
- [ ] Testadores adicionados

---

## 🐛 PROBLEMAS COMUNS

### "Permission denied (publickey)"
**Solução**: Use HTTPS ao invés de SSH:
```bash
git remote set-url origin https://github.com/SEU-USUARIO/app-financas.git
```

### "Support for password authentication was removed"
**Solução**: Use Personal Access Token como senha, não sua senha do GitHub.

### Workflow não aparece no Actions
**Solução**: 
1. Certifique-se que os arquivos estão em `.github/workflows/`
2. Dê push novamente:
```bash
git add .github/workflows/
git commit -m "Add workflows"
git push
```

### Build falhou no GitHub
**Solução**:
1. Clique no workflow que falhou
2. Veja os logs detalhados
3. Procure por linhas com "Error"
4. Corrija e faça push novamente

---

## 🎯 RESUMO DO QUE VOCÊ VAI FAZER

1. ✅ Instalar Git (5 min)
2. ✅ Criar conta GitHub (5 min)
3. ✅ Enviar código para GitHub (10 min)
4. ✅ Executar workflow Android (15 min)
5. ✅ Baixar e instalar APK (5 min)
6. 🍎 (Opcional) Configurar iOS (30 min)

**TEMPO TOTAL: 40 minutos** (sem iOS) ou **70 minutos** (com iOS)

---

## 🆘 PRECISA DE AJUDA?

Se travar em algum passo, me avise qual passo e qual erro apareceu!

---

## 🎉 BOA SORTE!

Siga este guia passo a passo e você terá seu app rodando no celular!

**COMECE INSTALANDO O GIT:** https://git-scm.com/download/win
