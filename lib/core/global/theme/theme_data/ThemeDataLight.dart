import 'package:flutter/material.dart';
import 'package:securemail/core/global/theme/app_color/AppColorLight.dart';


ThemeData getThemeLight() => ThemeData(
  primaryColor: AppColorLight.primaryColor,
  scaffoldBackgroundColor: AppColorLight.backgroundColor, 
  buttonTheme: ButtonThemeData(
    buttonColor: AppColorLight.buttonColor,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: AppColorLight.displaylarge),
    displayMedium: TextStyle(color: AppColorLight.displayMedium),
    displaySmall: TextStyle(color: AppColorLight.displaySmall,
    fontSize: 14),
  ),
  
  
  
  );