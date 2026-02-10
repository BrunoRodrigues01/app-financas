# 🔐 Como Assinar e Instalar iOS App

## 📱 3 Métodos para Instalar no iPhone

### Método 1: Desenvolvimento Local (Gratuito - 7 dias)

**Requisitos:**
- ✅ Mac com Xcode
- ✅ Apple ID (gratuito)
- ✅ iPhone conectado via cabo USB

**Passos:**

1. **Abra o projeto no Xcode:**
```bash
cd "caminho/para/App_Finanças"
open ios/Runner.xcworkspace
```

2. **Configure o Signing:**
   - No Xcode, selecione "Runner" no navegador
   - Vá em "Signing & Capabilities"
   - Marque "Automatically manage signing"
   - Selecione seu "Team" (sua Apple ID)
   - Mude o "Bundle Identifier" para algo único:
     `com.seuNome.minhasFinancas`

3. **Selecione seu iPhone:**
   - No topo do Xcode, selecione seu iPhone conectado
   - Pode aparecer "iPhone de [Seu Nome]"

4. **Confie no desenvolvedor (no iPhone):**
   - Ajustes → Geral → Gerenciamento de Dispositivo
   - Confie no certificado com seu Apple ID

5. **Execute:**
   - Clique no botão ▶️ (Play) no Xcode
   - O app será instalado no iPhone

**Limitações:**
- ⚠️ App expira em 7 dias
- ⚠️ Precisa reinstalar após 7 dias
- ⚠️ Máximo 3 apps simultaneamente

---

### Método 2: TestFlight (Recomendado para Testes)

**Requisitos:**
- ✅ Conta Apple Developer ($99/ano)
- ✅ Mac com Xcode

**Vantagens:**
- ✅ App válido por 90 dias
- ✅ Até 10.000 testadores
- ✅ Distribuição fácil (link)
- ✅ Feedback automático

**Passos:**

1. **Prepare o app:**
```bash
flutter build ios --release
```

2. **Archive no Xcode:**
   - Abra `ios/Runner.xcworkspace`
   - Product → Archive
   - Aguarde conclusão

3. **Upload para App Store Connect:**
   - Window → Organizer
   - Selecione o Archive
   - Clique "Distribute App"
   - Escolha "App Store Connect"
   - Upload

4. **Configure no App Store Connect:**
   - Acesse: https://appstoreconnect.apple.com
   - Vá em "TestFlight"
   - Adicione informações do teste
   - Adicione testadores (emails)

5. **Testadores instalam:**
   - Baixam app "TestFlight" da App Store
   - Aceitam convite
   - Instalam seu app

---

### Método 3: Distribuição Ad Hoc (Até 100 Dispositivos)

**Requisitos:**
- ✅ Conta Apple Developer ($99/ano)
- ✅ UDIDs dos iPhones que receberão o app

**Passos:**

1. **Registre dispositivos:**
   - Portal: https://developer.apple.com
   - Certificates, IDs & Profiles
   - Devices → Adicione UDID de cada iPhone

2. **Crie Provisioning Profile:**
   - Profiles → Ad Hoc
   - Selecione App ID
   - Selecione certificado
   - Selecione dispositivos
   - Gere e baixe

3. **Configure no Xcode:**
   - Adicione o provisioning profile
   - Build → Archive
   - Export → Ad Hoc

4. **Distribua o IPA:**
   - Envie o .ipa para testadores
   - Instalem via Xcode ou Apple Configurator

---

## 🔨 Comandos Úteis

### Verificar certificados disponíveis:
```bash
security find-identity -p codesigning -v
```

### Limpar build do iOS:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Ver dispositivos conectados:
```bash
flutter devices
```

### Instalar direto no iPhone conectado:
```bash
flutter install
```

---

## 🆘 Problemas Comuns

### "No matching provisioning profiles found"
**Solução:**
- Xcode → Preferences → Accounts
- Clique no + e adicione sua Apple ID
- Clique "Download Manual Profiles"

### "This application is not supported on this device"
**Solução:**
- No Xcode, vá em Runner → General
- Mude "Deployment Target" para iOS 12.0 ou inferior

### "The operation couldn't be completed"
**Solução:**
- No iPhone: Ajustes → Geral → Gerenciamento de Dispositivo
- Confie no desenvolvedor

### "Code signing is required"
**Solução:**
- Xcode → Runner → Signing & Capabilities
- Ative "Automatically manage signing"
- Selecione seu Team

### "iPhone is busy: Preparing debugger support"
**Solução:**
- Aguarde alguns minutos
- Ou: Desconecte e reconecte o iPhone

---

## 🎯 Recomendação por Situação

### Você quer apenas testar rapidamente:
→ **Método 1** (Desenvolvimento Local)
- Gratuito
- Rápido
- Expira em 7 dias

### Você quer testar com amigos/clientes:
→ **Método 2** (TestFlight)
- Profissional
- 90 dias
- Fácil distribuição

### Você quer controle total:
→ **Método 3** (Ad Hoc)
- Até 100 dispositivos
- Não precisa App Store Connect

### Você quer publicar na App Store:
→ **App Store Distribution**
- Disponível para todos
- Processo de revisão (1-7 dias)

---

## 📋 Checklist Completo

### Desenvolvimento Local (Gratuito):
- [ ] Tenho Mac com Xcode instalado
- [ ] Tenho Apple ID
- [ ] iPhone conectado via USB
- [ ] Configurei Signing no Xcode
- [ ] Confiei no desenvolvedor no iPhone
- [ ] App instalado e funcionando

### TestFlight:
- [ ] Tenho conta Apple Developer ($99/ano)
- [ ] Criei app no App Store Connect
- [ ] Fiz Archive no Xcode
- [ ] Fiz upload do build
- [ ] Adicionei testadores
- [ ] Testadores receberam convite

### Ad Hoc:
- [ ] Tenho conta Apple Developer
- [ ] Coletei UDIDs dos iPhones
- [ ] Registrei dispositivos no portal
- [ ] Criei Provisioning Profile
- [ ] Gerei IPA assinado
- [ ] Distribuí para testadores

---

## 💰 Custos

| Método | Custo Anual | Duração App | Testadores |
|--------|-------------|-------------|------------|
| Desenvolvimento Local | Grátis | 7 dias | Você | 
| TestFlight | $99 | 90 dias | 10.000 |
| Ad Hoc | $99 | Ilimitado | 100 |
| App Store | $99 | Ilimitado | Ilimitado |

---

## 🔗 Links Úteis

- **Apple Developer Portal**: https://developer.apple.com
- **App Store Connect**: https://appstoreconnect.apple.com
- **TestFlight**: https://testflight.apple.com
- **Documentação Flutter iOS**: https://docs.flutter.dev/deployment/ios

---

## ✅ Resumo

**Sem pagar nada:**
- Use GitHub Actions para gerar IPA
- Use método de desenvolvimento local
- Reinstale a cada 7 dias

**Pagando $99/ano:**
- Use TestFlight (melhor opção)
- Ou publique na App Store
- Distribuição profissional

**Escolha o método que melhor se adequa ao seu caso!**

---

**Precisa de mais ajuda? Consulte a documentação oficial da Apple! 📱**
