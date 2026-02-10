# Como Executar o App Minhas Finanças

## ⚠️ Importante: Configuração de Dispositivo

O Flutter precisa de um dispositivo para executar o aplicativo. Você tem várias opções:

## 🖥️ Opção 1: Habilitar suporte para Windows Desktop

1. Execute no terminal:
```bash
flutter config --enable-windows-desktop
```

2. Depois execute:
```bash
flutter run -d windows
```

## 🌐 Opção 2: Executar no navegador Chrome

1. Execute no terminal:
```bash
flutter run -d chrome
```

## 📱 Opção 3: Usar um emulador Android

### Instalar Android Studio:
1. Baixe o [Android Studio](https://developer.android.com/studio)
2. Instale e abra o Android Studio
3. Vá em Tools > Device Manager
4. Crie um novo dispositivo virtual (AVD)
5. Inicie o emulador

### Executar o app:
```bash
flutter run
```

## 🍎 Opção 4: Usar um emulador iOS (somente macOS)

1. Instale o Xcode
2. Execute:
```bash
open -a Simulator
flutter run
```

## 📲 Opção 5: Dispositivo físico

### Android:
1. Ative "Opções do desenvolvedor" no seu celular
2. Ative "Depuração USB"
3. Conecte o celular ao computador via USB
4. Execute: `flutter run`

### iOS:
1. Conecte o iPhone via USB
2. Execute: `flutter run`

## 🔧 Verificar dispositivos disponíveis

Para ver quais dispositivos estão disponíveis:
```bash
flutter devices
```

## 📦 Instalar dependências

Antes de executar, instale as dependências:
```bash
flutter pub get
```

## ✅ Verificar instalação do Flutter

Para verificar se está tudo ok:
```bash
flutter doctor
```

---

## 🎯 Recomendação para teste rápido:

**Use o Windows Desktop** (mais simples):
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

Ou **use o Chrome** (não precisa instalar nada):
```bash
flutter run -d chrome
```
