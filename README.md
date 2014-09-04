CappuccinoTranslator
====================

Multilingual Cappuccino applications without multiple CIB files...

## What is CappuccinoTranslator ?

CappuccinoTranslator, aka Translator, helps you in writing multilingual applications without having to maintain multiple CIB files (I personally hate dealing with multiple CIB files because I always forget to make changes in other languages).

Translator offers a variety of methods to ease your work, as, for example, some magic to autolayout buttons when translation modifies their width (see further in this document) or live language switching (e.g. without forcing the user to reload the application), etc.

In fact, to be honest, Translator offers a variety of methods to ease my work...

But if it can be of any help for you, I'll be happy...

## What is NOT Translator ?

Translator, even if it seems to have a magic wand, doesn't *automaticaly* translate your application. I mean, it can't, without any dictionary, create a Italian version of your Japanese application...

## What else is not Translator ?

Well, it's not :

- finished (some work needs to be done but it's fully functional)
- clean (well, of course, magic also means some hacks)
- bug free (but I hope it is)

## How to use Translator in your project ? (aka quick start guide)

- copy the folder "Translator" (containing the two source files) to the root folder of your project
- copy the folder "Translator" (the one located in the Resources folder) to your Resources folder
- edit your Info.plist and add :

    - TranslatorDefaultLanguage [String] XX (where XX is the locale corresponding to the language in which your application is designed, for example "fr" or "en")
    - TranslatorSupportedLanguages [Array] of [String] XX (where XX is a locale supported by your application, that is for which you provide a dictionary)
    - (optional) TranslatorLanguageUrlArgument [String] XXXX (see further in this doc for details)
    
    Please note that every locale specified here must exist in the Resources/Translator/TranslatorKnownLanguages.js file.
    
- add a XX.xstrings dictionary file for every locale your application supports, where XX is the corresponding locale (e.g. "fr", "de", ...). Sample files are provided in the Resources/Translator folder (I know, this was a huge and heavy work for me but I know I'll be rewarded in my next life)


You're almost done. Let's go to code now...

In your AppController.j, import the two Translator files :

    @import "Translator/TranslatorCategories.j"
    @import "Translator/TranslatorController.j"
    
At the end of your awakeFromCib method, add the Translator initialisation. Here is what I personally do :

    var theTranslator = [TranslatorController sharedTranslator];
    
The next line gives Translator access to all the views of your application :
    
    [theTranslator addViewsToViewsToTranslate:[[CPApplication sharedApplication] 
        topLevelViewsForTranslatorAutoLayout]];
    
Next, specify which main menu to translate :
    
    [theTranslator setMenuToTranslate:menu];
    
Then, if you have a toolbar, just tell Translator :

    [theTranslator setToolbarToTranslate:_myToolbar];
    
And, if you have TableViews, add them also :

    [theTranslator addTableViewToTranslate:tableView];
    
Now, you have to indicate which language you want to present to the user. Just use the *tryToSetLanguage* method. 

What this tries to do is :

1. If preferedLanguage is not nil and is supported, use it
2. If urlArgumentName is not nil and is available in the URL arguments, and is valid, use it
3. If canTryBrowserLanguage is YES, use the browser language
4. If nothing above worked, just use the default language as specified in the Info.plist

What I personally do is to first try to load user's preferences and if it's OK, pass it as the preferedLanguage argument. Then, as my app can be integrated behind a single sign on portal, I check for the argument named "userlang".

For example :

    [theTranslator tryToSetLanguage:(preferencesLoaded ? 
                                    [preferencesController valueForKey:@"langue"] : 
                                    nil) 
        ifNeededUseUrlArgumentNamed:@"userlang" 
         ifNeededUseBrowserLanguage:YES];

If you have a login panel, you can include a language menu and keep the user's choice as preferedLanguage.

The method returns the language that has been set (I save it as the user prefered language).


And... Voilà ! Translator is working quietly...


If you read until here, you should have a question in mind...

*"But how do I specify what is to translate ?"*

Well, it's easy (remember that I personally use Translator to minimise the work I must do to have a multilingual application, so it has to be easy).

So, all you have to do is to design your UI in your own language (which is then the default language, this is very important) and just put [[ and ]] around text to translate. This can be done in Interface Builder, or in your programmatic UI, or whatever string that will be displayed (even in data...).

Of course, you have to put in each language dictionary the translation like this :

    <key>J'aime Cappuccino !</key><string>I love Cappuccino !</string>

(the key is simply the text between [[ and ]])

So you can do something like :

    [aButton setTitle:@"[[J'aime Cappuccino !]]"];
    
Your UI and your code is still easily readable, so easy to maintain.

## Language switching

I imagine you'll want to have some kind of preference panel letting the user choose its prefered language. 

To do so, you will put a popup button. That's a great idea. And Translator will help you.

In your awakeFromCib (or where you like to put it), use :

    [buttonLanguage removeAllItems];

    [buttonLanguage addItemsWithTitles:
        [[TranslatorController sharedTranslator] supportedLanguagesNames]];
    
Then, if oldLocale contains the current language :

    [buttonLanguage selectItemWithTitle:
        [[TranslatorController sharedTranslator] languageNameForLanguage:oldLocale]];

Now, let the user choose a language and perform whatever confirmation you like. Then :

    var newLocale = [[TranslatorController sharedTranslator] 
        languageForLanguageName:[buttonLanguage title]];
        
If newLocale is different from oldLocale, it's time de change your UI language :

    [[TranslatorController sharedTranslator] setLanguage:newLocale];

And in a snap (or an eye blink), your app turns from Russian to Swedish.


## Autolayout

Using a single CIB file for multiple languages is sometimes hard as text width may vary a lot (for example, "birthday" is shorter than its French counterpart "anniversaire").

In most case, it's easy to handle : 

- right align labels that are before fields / popup / ...
- sometimes just use wider controls, textfields, ...
- etc

But when you have, say a dialog like a preference pane, and that you precisely right aligned your beautiful buttons (from right to left) "Save" & "Cancel" and when your user just switch to another language, everything may become messy (and you don't like that, of course, just look at your desktop...  ;)

You can then use the Translator autolayout feature. Simply add those two user defined runtime attributes on your two buttons :

    keepRight <number> xx
    minWidth  <number> yy
    
where xx is the distance to keep from the right neighbor (or border if the button is the first) and yy is the minimum width for the button.

Of course, keepLeft has the same effect but from left to right.

By experience, I personally use 18 as xx and 100 as yy on both "Save" & "Cancel" buttons.


## Some other utilities

Returns the current locale :

    [[TranslatorController sharedTranslator] currentLanguage];

Returns the current language name :

    [[TranslatorController sharedTranslator] currentLanguageName];

Returns an array with all supported locales :

    [[TranslatorController sharedTranslator] supportedLanguages];

Returns an array with all supported languages :

    [[TranslatorController sharedTranslator] supportedLanguagesNames];

Returns the locale corresponding to the language :

    [[TranslatorController sharedTranslator] languageFromLanguageName:@"Français"];
    
Returns the language corresponding to the locale :

    [[TranslatorController sharedTranslator] languageNameFromLanguage:@"fr"];

Return the browser language :

    [[TranslatorController sharedTranslator] browserLanguage];

Return the default language :

    [[TranslatorController sharedTranslator] defaultLanguage];

Return YES if Translator can handle the locale :

    [[TranslatorController sharedTranslator] canSupportLanguage:@"it"];


## What's next ?

As soon as I can find time, here is my to-do list :

- try to manage vertical positioning as well as horizontal is done today
- add various checking
- fix a positioning problem in toolbars
- try to write a tool that can extract strings from CIB and code and create dictionaries


