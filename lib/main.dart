import 'package:flutter/material.dart';
// CORRECCIÓN: Quitamos el "lib/" del principio
import 'theme.dart';
import 'screens/lobby.dart';

void main() {
  runApp(const DuoThemeApp());
}

class DuoThemeApp extends StatelessWidget {
  const DuoThemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: AppTheme.colorNotifier,
      builder: (context, newColor, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: duoBg,
              dialogBackgroundColor: duoSurface,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: newColor,
                secondary: newColor,
              ),
              sliderTheme: SliderThemeData(
                activeTrackColor: newColor,
                thumbColor: newColor,
                inactiveTrackColor: duoBorder,
              ),
              switchTheme: SwitchThemeData(
                // Nota: En Flutter muy nuevo, usa WidgetStateProperty en vez de MaterialStateProperty
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) return newColor;
                  return duoTextSub;
                }),
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) return newColor.withOpacity(0.5);
                  return duoBorder;
                }),
              )
          ),
          home: const MenuLobby(),
        );
      },
    );
  }
}