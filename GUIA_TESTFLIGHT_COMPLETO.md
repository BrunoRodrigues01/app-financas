# 🎉 Guia Completo - TestFlight com Apple Developer

Você tem uma conta Apple Developer! Isso é ótimo! Vou te guiar passo a passo para publicar seu app no TestFlight.

---

## 📋 O Que Você Vai Fazer:

1. ✅ Criar o App no App Store Connect
2. ✅ Gerar Certificados e Perfis
3. ✅ Configurar GitHub Secrets
4. ✅ Fazer Upload Automático
5. ✅ Convidar Testadores

**Tempo estimado: 30-40 minutos (primeira vez)**

---

## 🔧 Parte 1: Configurar App Store Connect

### Passo 1: Criar o App

1. Acesse: https://appstoreconnect.apple.com
2. Clique em **"My Apps"** → **"+"** → **"New App"**
3. Preencha:
   - **Platform**: iOS
   - **Name**: Minhas Finanças
   - **Primary Language**: Portuguese (Brazil)
   - **Bundle ID**: Crie novo → `com.seuNome.minhasFinancas`
   - **SKU**: `minhas-financas-001`
4. Clique **"Create"**

### Passo 2: Preencher Informações Básicas

1. Vá em **"App Information"**
2. Preencha:
   - **Category**: Finance
   - **Subtitle**: Controle suas finanças pessoais
   - **Privacy Policy URL**: (opcional para TestFlight)

---

## 🔐 Parte 2: Gerar Certificados (No Mac)

### Passo 1: Criar Certificate Signing Request (CSR)

**No Mac:**

1. Abra **"Keychain Access"** (Acesso às Chaves)
2. Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Preencha:
   - **User Email Address**: seu@email.com
   - **Common Name**: Seu Nome
   - **CA Email**: deixe vazio
   - **Request is**: Saved to disk
4. Salve como: `CertificateSigningRequest.certSigningRequest`

### Passo 2: Criar Distribution Certificate

1. Acesse: https://developer.apple.com/account/resources/certificates
2. Clique **"+"** → **"Apple Distribution"**
3. Faça upload do CSR criado
4. Baixe o certificado: `distribution.cer`
5. Dê duplo clique para instalar no Keychain

### Passo 3: Exportar Certificado para P12

**No Mac - Keychain Access:**

1. Encontre o certificado instalado: **"Apple Distribution: Seu Nome"**
2. Clique com botão direito → **"Export"**
3. Salve como: `Certificates.p12`
4. **IMPORTANTE**: Defina uma senha forte (você vai precisar dela)

### Passo 4: Converter P12 para Base64

```bash
# No Terminal do Mac:
base64 -i Certificates.p12 -o certificate_base64.txt
```

Guarde o conteúdo do arquivo `certificate_base64.txt` (uma string longa).

---

## 📱 Parte 3: Criar Provisioning Profile

### Passo 1: Registrar App ID

1. Acesse: https://developer.apple.com/account/resources/identifiers
2. Clique **"+"** → **"App IDs"** → **"App"**
3. Preencha:
   - **Description**: Minhas Finanças
   - **Bundle ID**: Explicit → `com.seuNome.minhasFinancas`
4. Clique **"Continue"** → **"Register"**

### Passo 2: Criar Provisioning Profile

1. Acesse: https://developer.apple.com/account/resources/profiles
2. Clique **"+"** → **"App Store"**
3. Selecione:
   - **App ID**: com.seuNome.minhasFinancas
   - **Certificate**: Seu certificado de distribuição
4. Clique **"Generate"**
5. Baixe: `MinhasFinancas_AppStore.mobileprovision`

### Passo 3: Converter Provisioning Profile para Base64

```bash
# No Terminal do Mac:
base64 -i MinhasFinancas_AppStore.mobileprovision -o provisioning_base64.txt
```

Guarde o conteúdo do arquivo `provisioning_base64.txt`.

---

## 🔑 Parte 4: Criar App-Specific Password

1. Acesse: https://appleid.apple.com
2. Faça login com seu Apple ID
3. Vá em **"Sign-In and Security"** → **"App-Specific Passwords"**
4. Clique **"Generate Password"**
5. Nome: `GitHub Actions TestFlight`
6. **GUARDE A SENHA** (você não verá novamente)

---

## 🔒 Parte 5: Configurar GitHub Secrets

### Passo 1: Encontrar seu Team ID

1. Acesse: https://developer.apple.com/account
2. No topo da página, seu **Team ID** está ao lado do nome
3. Ex: `AB12CD34EF`

### Passo 2: Adicionar Secrets no GitHub

1. Acesse seu repositório no GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Clique **"New repository secret"**

Adicione cada um destes secrets:

| Nome do Secret | Valor |
|----------------|-------|
| `APPLE_CERTIFICATE_BASE64` | Conteúdo de `certificate_base64.txt` |
| `APPLE_CERTIFICATE_PASSWORD` | Senha que você definiu no P12 |
| `PROVISIONING_PROFILE_BASE64` | Conteúdo de `provisioning_base64.txt` |
| `APPLE_ID` | Seu email da Apple ID |
| `APPLE_APP_SPECIFIC_PASSWORD` | Senha gerada no Passo 4 |
| `APPLE_TEAM_ID` | Seu Team ID (ex: AB12CD34EF) |

---

## ⚙️ Parte 6: Configurar o Projeto Flutter

### Passo 1: Atualizar Bundle ID

Edite: `ios/Runner.xcodeproj/project.pbxproj`

Ou mais fácil, no Xcode:

1. Abra: `ios/Runner.xcworkspace`
2. Selecione **"Runner"** no navegador
3. Em **"General"**:
   - **Bundle Identifier**: `com.seuNome.minhasFinancas`
   - **Version**: `1.0.0`
   - **Build**: `1`

### Passo 2: Atualizar ExportOptions.plist

Edite: `ios/ExportOptions.plist`

Substitua:
- `YOUR_TEAM_ID` → Seu Team ID (ex: AB12CD34EF)
- `com.seuNome.minhasFinancas` → Seu Bundle ID
- `YOUR_PROVISIONING_PROFILE_NAME` → Nome do seu perfil

---

## 🚀 Parte 7: Fazer o Deploy!

### Método 1: Via GitHub Actions (Automático)

1. **Commit e Push:**
```bash
git add .
git commit -m "Configuração para TestFlight"
git push
```

2. **Criar uma Tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

3. **Aguarde:**
   - Vá em **Actions** no GitHub
   - Veja o workflow rodando
   - Aguarde 15-20 minutos

4. **Verifique no App Store Connect:**
   - Acesse: https://appstoreconnect.apple.com
   - Vá em seu app → **TestFlight**
   - O build aparecerá em "Processing" (5-30 min)

### Método 2: Via Mac (Manual)

Se preferir fazer manualmente no Mac:

```bash
# 1. Prepare o build
flutter clean
flutter pub get
flutter build ios --release

# 2. Abra no Xcode
open ios/Runner.xcworkspace

# 3. No Xcode:
# Product → Archive
# Aguarde conclusão
# Window → Organizer
# Distribute App → App Store Connect
# Upload
```

---

## 👥 Parte 8: Adicionar Testadores

### Passo 1: Aguardar Processamento

Após o upload, aguarde o build ser processado (status: "Ready to Submit").

### Passo 2: Criar Grupo de Teste

1. No App Store Connect → **TestFlight**
2. Clique em **"Internal Testing"** ou **"External Testing"**
3. Clique **"+"** → **"Create Group"**
4. Nome: `Beta Testers`

### Passo 3: Adicionar Testadores

1. Clique no grupo criado
2. **"Add Testers"** → **"+"**
3. Digite o email de cada testador
4. Eles receberão convite por email

### Passo 4: Testadores Instalam

1. Baixam app **"TestFlight"** da App Store
2. Aceitam o convite recebido por email
3. Instalam seu app no TestFlight
4. Testam e enviam feedback

---

## ✅ Checklist Completo

### Setup Inicial (Uma vez):
- [ ] Conta Apple Developer ativa ($99/ano)
- [ ] App criado no App Store Connect
- [ ] Bundle ID registrado
- [ ] Certificate de distribuição criado
- [ ] Provisioning Profile criado
- [ ] App-Specific Password gerada
- [ ] GitHub Secrets configurados
- [ ] ExportOptions.plist atualizado

### Para Cada Release:
- [ ] Código testado e funcionando
- [ ] Versão atualizada em pubspec.yaml
- [ ] Commit e push no GitHub
- [ ] Tag criada (ex: v1.0.1)
- [ ] Workflow executado com sucesso
- [ ] Build processado no App Store Connect
- [ ] Testadores notificados

---

## 🐛 Troubleshooting

### "No matching provisioning profile found"
**Solução:**
- Verifique se o Bundle ID está correto em todos os lugares
- Verifique se o Provisioning Profile está ativo

### "Certificate has expired"
**Solução:**
- Gere novo certificado no portal
- Atualize o GitHub Secret `APPLE_CERTIFICATE_BASE64`

### "Invalid signature"
**Solução:**
- Verifique a senha do certificado
- Recrie o P12 e converta novamente para Base64

### "Build processing failed"
**Solução:**
- Verifique os logs no App Store Connect
- Certifique-se de que não há erros de compilação
- Aumente o número do Build

### "Workflow failed on GitHub"
**Solução:**
- Veja os logs detalhados no Actions
- Verifique se todos os Secrets estão configurados
- Teste o build localmente primeiro

---

## 📊 Resumo dos Custos

| Item | Custo | Frequência |
|------|-------|------------|
| Apple Developer | $99 | Anual |
| GitHub (privado) | Grátis | - |
| GitHub Actions | Grátis* | - |
| TestFlight | Grátis | - |
| Certificados | Grátis | - |

*GitHub Actions: 2000 minutos/mês grátis

---

## 🎯 Próximos Passos

1. **Agora**: Configure tudo seguindo este guia
2. **Depois**: Teste com grupo pequeno (5-10 pessoas)
3. **Em seguida**: Expanda para mais testadores
4. **Por fim**: Publique na App Store (se quiser)

---

## 📱 Dicas Importantes

### Para TestFlight:
- ✅ Builds expiram em 90 dias
- ✅ Máximo 10.000 testadores externos
- ✅ Feedback automático de crashes
- ✅ Pode ter várias versões em teste

### Para App Store (quando publicar):
- ⚠️ Revisão leva 1-7 dias
- ⚠️ Pode ser rejeitado (siga as diretrizes)
- ⚠️ Precisa de screenshots (obrigatório)
- ⚠️ Precisa de ícone profissional

---

## 🔗 Links Úteis

- **App Store Connect**: https://appstoreconnect.apple.com
- **Developer Portal**: https://developer.apple.com/account
- **Apple ID**: https://appleid.apple.com
- **TestFlight Help**: https://developer.apple.com/testflight/
- **Guidelines iOS**: https://developer.apple.com/app-store/review/guidelines/

---

## 🆘 Precisa de Ajuda?

Se encontrar algum problema:

1. Consulte a seção **Troubleshooting** acima
2. Veja os logs detalhados no GitHub Actions
3. Consulte a documentação oficial da Apple
4. Verifique o Stack Overflow

---

**Boa sorte com seu app no TestFlight! 🚀**

Se precisar de ajuda em algum passo específico, é só me avisar!
