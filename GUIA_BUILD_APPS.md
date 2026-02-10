# 📱 Guia de Build iOS e Android

## 🎯 Opções para Gerar Builds

### Opção 1: GitHub Actions (Recomendado - GRATUITO!)

#### Passo 1: Criar Repositório no GitHub
```bash
# Na pasta do projeto, inicialize o git:
git init
git add .
git commit -m "Initial commit"

# Crie um repositório no GitHub e conecte:
git remote add origin https://github.com/seu-usuario/seu-repositorio.git
git branch -M main
git push -u origin main
```

#### Passo 2: Executar o Build
1. Acesse seu repositório no GitHub
2. Clique na aba **"Actions"**
3. Você verá dois workflows:
   - 🍎 **Build iOS**
   - 🤖 **Build Android**
4. Clique em "Run workflow" no workflow desejado
5. Aguarde 5-15 minutos
6. Baixe o arquivo gerado nos **"Artifacts"**

#### Vantagens:
- ✅ **100% Gratuito**
- ✅ Build automático a cada push
- ✅ Funciona sem Mac
- ✅ 2000 minutos/mês grátis

---

### Opção 2: Build Local (Android)

Se você quiser gerar o APK agora no seu Windows:

```bash
# No terminal do VS Code:
flutter clean
flutter pub get
flutter build apk --release

# O APK estará em:
# build/app/outputs/flutter-apk/app-release.apk
```

**Como instalar no Android:**
1. Copie o APK para o celular (Google Drive, WhatsApp, etc)
2. No celular, ative "Instalar apps de fontes desconhecidas"
3. Abra o APK e instale

---

### Opção 3: Serviços Alternativos

#### **Bitrise** (200 builds/mês grátis)
🔗 https://bitrise.io

1. Crie conta e conecte seu repositório
2. Escolha "Flutter" como tipo de projeto
3. Configure para iOS ou Android
4. Execute o build
5. Baixe o arquivo gerado

#### **CircleCI** (6000 minutos/mês grátis)
🔗 https://circleci.com

Similar ao GitHub Actions, mas com interface diferente.

#### **AppVeyor** (Open Source)
🔗 https://www.appveyor.com

Gratuito apenas para projetos públicos.

---

## 🍎 Build iOS Específico

### Sem Mac - Usando GitHub Actions:

O arquivo `.github/workflows/ios-build.yml` já está configurado!

**Importante:** O IPA gerado não estará assinado. Para instalar no iPhone:

#### Método 1: Assinar Localmente (precisa de Mac)
```bash
# No Mac, após baixar o IPA:
# 1. Extraia o IPA
unzip app-release.ipa

# 2. Abra no Xcode
open Payload/Runner.app

# 3. Assine com sua Apple ID e instale no iPhone conectado
```

#### Método 2: Configurar Assinatura no GitHub (Avançado)

Você precisa adicionar seus certificados Apple nos **Secrets** do GitHub:
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `PROVISIONING_PROFILE_BASE64`
- `APPLE_TEAM_ID`

Depois, o workflow assinará automaticamente.

---

## 🤖 Build Android Específico

### Opção A: GitHub Actions
O arquivo `.github/workflows/android-build.yml` já está configurado!

Gera dois arquivos:
- **APK**: Para instalar diretamente
- **AAB**: Para publicar na Play Store

### Opção B: Build Local (Windows)

```bash
# APK (para instalar manualmente)
flutter build apk --release

# App Bundle (para Play Store)
flutter build appbundle --release

# APK dividido por arquitetura (menor tamanho)
flutter build apk --split-per-abi --release
```

Arquivos gerados:
- `build/app/outputs/flutter-apk/app-release.apk` (universal)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (emulador)

---

## 🔐 Publicar nas Lojas

### Google Play Store (Android)
1. Crie conta de desenvolvedor ($25 único)
2. Gere o AAB: `flutter build appbundle --release`
3. Faça upload do AAB na Play Console
4. Preencha as informações do app
5. Publique

### Apple App Store (iOS)
1. Conta Apple Developer ($99/ano)
2. Gere o IPA assinado
3. Faça upload via Xcode ou Application Loader
4. Submeta para revisão
5. Aguarde aprovação (1-7 dias)

---

## 📊 Comparação de Opções

| Serviço | Custo | Minutos/Mês | iOS | Android | Fácil |
|---------|-------|-------------|-----|---------|-------|
| **GitHub Actions** | Grátis | 2000 | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| **Bitrise** | Grátis | ~200 builds | ✅ | ✅ | ⭐⭐⭐⭐ |
| **CircleCI** | Grátis | 6000 | ✅ | ✅ | ⭐⭐⭐ |
| **Codemagic** | $0-99 | 500/mês | ✅ | ✅ | ⭐⭐⭐⭐ |
| **Build Local** | Grátis | Ilimitado | ❌* | ✅ | ⭐⭐⭐⭐⭐ |

*iOS local requer Mac

---

## 🆘 Problemas Comuns

### "Error: No iOS devices found"
- Certifique-se de que o iPhone está conectado via USB
- Confie no computador no iPhone
- Execute: `flutter devices`

### "Error: JAVA_HOME not set"
```bash
# Instale Java JDK 17
# Windows: https://www.oracle.com/java/technologies/downloads/
# Defina JAVA_HOME nas variáveis de ambiente
```

### "Error: Android SDK not found"
```bash
# Execute:
flutter doctor
# Siga as instruções para instalar o Android SDK
```

### APK muito grande
```bash
# Use split por arquitetura:
flutter build apk --split-per-abi --release
# Cada APK terá ~20-30MB ao invés de 50-60MB
```

---

## 💡 Dicas

1. **Teste antes de publicar**: Use TestFlight (iOS) ou Google Play Internal Testing (Android)
2. **Versão**: Atualize em `pubspec.yaml` a cada release
3. **Ícone**: Use um ícone profissional (512x512px mínimo)
4. **Screenshots**: Tire capturas de tela bonitas
5. **Descrição**: Escreva uma boa descrição do app

---

## 🚀 Próximos Passos

**Para começar agora:**

1. ✅ **Crie repositório no GitHub**
2. ✅ **Faça push do código**
3. ✅ **Execute o workflow iOS ou Android**
4. ✅ **Baixe o arquivo gerado**
5. ✅ **Instale no celular**

**Precisa de ajuda?**
- GitHub Actions: https://docs.github.com/actions
- Flutter Build: https://docs.flutter.dev/deployment
- Bitrise: https://devcenter.bitrise.io/

---

## 📞 Suporte

Se tiver dúvidas:
1. Verifique a documentação oficial do Flutter
2. Confira os logs do build no GitHub Actions
3. Procure no Stack Overflow
4. Abra uma issue no GitHub

**Boa sorte com seu app! 🎉**
