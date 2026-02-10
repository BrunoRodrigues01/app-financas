# 🚀 Como Gerar App para Celular - GUIA RÁPIDO

## ⚡ Jeito Mais Rápido (Android - AGORA!)

Execute no terminal do VS Code:

```bash
flutter build apk --release
```

✅ O arquivo APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

**Como instalar:**
1. Envie o APK para seu Android (WhatsApp, Drive, etc)
2. No celular, ative "Fontes desconhecidas" nas Configurações
3. Abra o APK e instale

---

## 🍎 Para iOS (Sem Mac) - GitHub Actions

### Passo a Passo:

1. **Suba para o GitHub:**
```bash
git init
git add .
git commit -m "App de finanças completo"
git remote add origin https://github.com/SEU-USUARIO/app-financas.git
git push -u origin main
```

2. **Execute o Build:**
   - Abra seu repositório no GitHub
   - Clique em **"Actions"**
   - Clique em **"Build iOS"**
   - Clique em **"Run workflow"**
   - Aguarde 10-15 minutos

3. **Baixe o IPA:**
   - Após concluir, baixe nos **"Artifacts"**

---

## 🎯 Alternativas GRATUITAS (sem Mac):

### 1️⃣ GitHub Actions (Recomendado)
- ✅ **Grátis**: 2000 minutos/mês
- ✅ **Automático**: Build a cada push
- ✅ **Já configurado**: Workflows criados!

### 2️⃣ Bitrise
- 🔗 https://bitrise.io
- ✅ 200 builds/mês grátis
- ✅ Interface visual

### 3️⃣ CircleCI
- 🔗 https://circleci.com
- ✅ 6000 minutos/mês grátis

---

## 📱 Comparação Rápida

| Método | iOS | Android | Precisa Mac? | Grátis? | Tempo |
|--------|-----|---------|--------------|---------|-------|
| **Build Local** | ❌ | ✅ | Não | ✅ | 5 min |
| **GitHub Actions** | ✅ | ✅ | Não | ✅ | 15 min |
| **Bitrise** | ✅ | ✅ | Não | ✅ | 20 min |
| **Com Mac** | ✅ | ✅ | Sim | ✅ | 10 min |

---

## 💡 Minha Recomendação

**Você quer testar agora?**
→ Use: `flutter build apk --release` (Android)

**Você quer iOS sem Mac?**
→ Use: GitHub Actions (já está configurado!)

**Você tem Mac?**
→ Use: Xcode direto

---

## 📄 Documentação Completa

Leia: **GUIA_BUILD_APPS.md** (criado na pasta do projeto)

---

## 🆘 Precisa de Ajuda?

**Erro ao buildar?**
```bash
flutter clean
flutter pub get
flutter doctor
```

**Quer ver dispositivos disponíveis?**
```bash
flutter devices
```

**Quer testar direto no celular conectado?**
```bash
flutter run
```

---

## ✅ Checklist

- [ ] Código compilando sem erros
- [ ] Testou no navegador (Chrome)
- [ ] Escolheu método de build (Local ou GitHub)
- [ ] Gerou APK/IPA
- [ ] Instalou no celular
- [ ] App funcionando!

---

**Pronto para começar? Execute o comando e boa sorte! 🎉**
