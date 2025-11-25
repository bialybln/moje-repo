# FuturesRocket

FuturesRocket to premiumowa, w pełni lokalna aplikacja iOS (SwiftUI + MVVM) pomagająca wyliczać pozycje futures oparte na ryzyku, zapisywać dziennik transakcji i śledzić progres kapitału w stronę wyznaczonego celu. Projekt celuje w iPhone 16 i iOS 26 (przygotowany w Xcode 15+), korzysta wyłącznie z lokalnej persystencji (UserDefaults + Codable) i nie wymaga backendu.

## Wymagania
- Xcode 15 lub nowszy
- iOS 17+ (projektowane pod iOS 26 / iPhone 16)
- Swift 5.9+

## Uruchomienie
1. Otwórz `FuturesRocket.xcodeproj` w Xcode.
2. Wybierz schemat **FuturesRocket**, urządzenie iPhone (np. symulator iPhone 16, gdy będzie dostępny) i uruchom (`⌘R`).
3. Aplikacja startuje w trybie dark mode z dolnym TabBarem (Home / History / Settings).

## Struktura katalogów
- `FuturesRocket/` – źródła aplikacji (SwiftUI + MVVM), zasoby i Info.plist.
- `FuturesRocket/Models` – modele danych i konfiguracji.
- `FuturesRocket/Services` – logika persystencji i kalkulator pozycji.
- `FuturesRocket/ViewModels` – źródła stanu i logiki ekranów.
- `FuturesRocket/Views` – widoki SwiftUI (Home, History, Settings + komponenty).
- `FuturesRocket/Resources/Assets.xcassets` – kolory, placeholdery, AppIcon.
- `FuturesRocketTests/` – przykładowe testy jednostkowe kalkulatora i PnL.

## Opis głównych ekranów
- **Home (Position Calculator)**: gradientowy header z kapitałem, kalkulator pozycji (entry/SL, DCA, TP), walidacje, podsumowanie jednostek/avg entry/risk, przycisk **Save trade** otwierający sheet z wyborem outcome (SL/BE/TP).
- **History**: pasek progresu kapitału vs cel, animowany „ludzik” na pasku, lista zapisanych tradów, przejście do `TradeDetailView` z notatkami.
- **Settings**: formularz kapitału początkowego, bieżącego (reset), ryzyka % i celu kapitału; zmiany zapisują się automatycznie.

## Logika kalkulatora (skrót)
- Ryzyko globalne: `riskAmount = accountCapital * riskPercent / 100`.
- Bez DCA: `units = riskAmount / abs(entry - stopLoss)`.
- Z DCA: suma udziałów ryzyka (entry + DCA) = 100%; dla każdej nogi `units_i = (riskAmount * share_i / 100) / perUnitRisk`; `totalUnits = sum(units_i)`; `avgEntry = weighted(price_i, units_i)`.
- TP: `unitsToClose = totalUnits * trimPercent / 100` (dla każdego TP).
- PnL: long = `(exit - avgEntry) * units`; short = `(avgEntry - exit) * units`; TP wariant sumuje zredukowane części i pozostałość na ostatnim TP.
- Po zapisaniu trade’u kapitał aktualizuje się o `realizedPnL` i zapisuje w UserDefaults.

## Git – szybki start
```bash
git init
git add .
git commit -m "Initial FuturesRocket implementation"
git branch -M main
git remote add origin <url>
git push -u origin main
```

## Notatki projektowe
- UI inspirowany premium fintech (Revolut/N26): glassmorphism, gradient #021B79 → #0575E6, tło #050509, akcenty profit/loss.
- Typografia: SF Pro Rounded, predefiniowane w `AppTypography`.
- Wszystkie dane lokalne (UserDefaults) – brak backendu.
- Haptics na kluczowych interakcjach (przyciski, zapis trade’u).
