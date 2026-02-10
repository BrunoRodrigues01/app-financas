# 🚀 Quick Start - TestFlight (Com Apple Developer)

## ⚡ Você Tem Conta Apple Developer? Siga Estes Passos:

### 📱 Setup Rápido (30 minutos):

#### 1️⃣ No App Store Connect:
```
1. https://appstoreconnect.apple.com
2. My Apps → + → New App
3. Nome: "Minhas Finanças"
4. Bundle ID: com.seuNome.minhasFinancas
5. Create
```

#### 2️⃣ No Developer Portal:
```
1. https://developer.apple.com/account
2. Certificates → + → Apple Distribution
3. Profiles → + → App Store
4. Download ambos
```

#### 3️⃣ No Mac (Keychain):
```bash
# Exportar certificado para P12
# Converter para Base64:
base64 -i Certificates.p12 -o cert.txt
base64 -i Profile.mobileprovision -o profile.txt
```

#### 4️⃣ No Apple ID:
```
1. https://appleid.apple.com
2. Sign-In and Security → App-Specific Passwords
3. Generate → "GitHub Actions"
4. Guarde a senha
```

#### 5️⃣ No GitHub:
```
Settings → Secrets → Actions → New secret

Adicione 6 secrets:
- APPLE_CERTIFICATE_BASE64
- APPLE_CERTIFICATE_PASSWORD
- PROVISIONING_PROFILE_BASE64
- APPLE_ID
- APPLE_APP_SPECIFIC_PASSWORD
- APPLE_TEAM_ID
```

#### 6️⃣ Deploy:
```bash
git add .
git commit -m "Deploy to TestFlight"
git tag v1.0.0
git push origin v1.0.0
```

✅ **Pronto! Em 15-20 minutos estará no TestFlight!**

---

## 📋 Ou Prefere Fazer Manual no Mac?

```bash
# 1. Build
flutter build ios --release

# 2. Xcode
open ios/Runner.xcworkspace

# 3. No Xcode:
Product → Archive
Window → Organizer
Distribute App → App Store Connect
Upload
```

---

## 👥 Adicionar Testadores:

```
1. App Store Connect → TestFlight
2. Aguardar build processar (5-30 min)
3. Create Group → Nome: "Beta"
4. Add Testers → Emails
5. Testers baixam TestFlight app
6. Instalam seu app
```

---

## 🔥 Cheat Sheet - Comandos Úteis:

```bash
# Ver Team ID
https://developer.apple.com/account

# Converter para Base64
base64 -i arquivo.p12 -o output.txt

# Build Flutter
flutter build ios --release

# Criar tag
git tag v1.0.1 && git push origin v1.0.1

# Ver dispositivos
flutter devices

# Limpar build
flutter clean && cd ios && pod install
```

---

## 📖 Documentação Completa:

Leia: **`GUIA_TESTFLIGHT_COMPLETO.md`**

---

## ✅ Tudo Pronto!

Arquivos criados para você:
- ✅ `.github/workflows/testflight-deploy.yml` - Deploy automático
- ✅ `ios/ExportOptions.plist` - Configuração de export
- ✅ `GUIA_TESTFLIGHT_COMPLETO.md` - Guia detalhado

**Siga os passos e em 30-40 minutos seu app estará no TestFlight! 🎉**
