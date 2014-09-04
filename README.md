CappuccinoTranslator
====================

Multilingual Cappuccino applications without multiple CIB files...

## What is CappuccinoTranslator ?

CappuccinoTranslator, aka Translator, is a collection of categories and a controller that helps you in writing multilingual applications without having to maintain multiple CIB files.

Translator offers a variety of methods to ease your work.

In fact, to be honest, Translator offers a variety of methods to ease my work...

But if it can be of any help for you, I'll be happy...

## What is NOT Translator ?

Translator, even if it seems to have a magic wand, doesn't *automaticaly* translate your application. I mean, it can't, without any dictionary, create a Italian version of your Japanese application...

## What else is not Translator ?

Well, it's not :

- finished (some work needs to be done but it's fully functional)
- clean (well, of course, magic also means some hacks)
- bug free (but I hope it is)

## How to install Translator in your project ?

- copy the folder "Translator" (containing the two source files) to the root folder of your project
- copy the folder "Translator" (the one located in the Resources folder) to your Resources folder
- edit your Info.plist and add :

    - TranslatorDefaultLanguage [String] XX (where XX is the locale corresponding to the language in which your application is designed, for example "fr" or "en")
    - TranslatorSupportedLanguages [Array] of [String] XX (where XX is a locale supported by your application, that is for which you provide a dictionary)
    - (optional) TranslatorLanguageUrlArgument [String] XXXX (see further in this doc for details)
    
    Please note that every locale specified here must exist in the Resources/Translator/TranslatorKnownLanguages.js file.

Next to-do : complete this file...  ;)
