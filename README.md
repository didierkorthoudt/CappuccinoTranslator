CappuccinoTranslator
====================

Multilingual Cappuccino applications without multiple CIB files...

## What is CappuccinoTranslator ?

CappuccinoTranslator, aka Translator, is a collection of categories and a controller that helps you in writing multilingual applications without having to maintain multiple CIB files.

Translator offers a variety of methods to ease your work, as, for example, some magic to autolayout buttons when translation modifies their width (see further in this document).

In fact, to be honest, Translator offers a variety of methods to ease my work...

But if it can be of any help for you, I'll be happy...

## What is NOT Translator ?

Translator, even if it seems to have a magic wand, doesn't *automaticaly* translate your application. I mean, it can't, without any dictionary, create a Italian version of your Japanese application...

## What else is not Translator ?

Well, it's not :

- finished (some work needs to be done but it's fully functional)
- clean (well, of course, magic also means some hacks)
- bug free (but I hope it is)

## How to use Translator in your project ? (aka quick start)

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

"But how do I specify what is to translate ?"

Well, it's easy (remember that I personally use Translator to minimise the work I must do to have a multilingual application, so it has to be easy).

So, all you have to do is to design your UI in your own language (which is then the default language, this is very important) and just put [[ and ]] around text to translate. This can be done in Interface Builder, or in your programmatic UI, or whatever string that will be displayed (even in data...).

Of course, you have to put in each language dictionary the translation like this :

    <key>J'aime Cappuccino !</key><string>I love Cappuccino !</string>

(the key is simply the text between [[ and ]])

So you can do something like :

    [aButton setTitle:@"[[J'aime Cappuccino !]]"];
    
Your UI and your code is still easily readable, so easy to maintain.

## There's more...


Next to-do : complete this file...  ;)
