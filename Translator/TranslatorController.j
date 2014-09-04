/*
 * TranslatorController.j
 *
 * Copyright (C) 2014 Didier Korthoudt <didier.korthoudt@icloud.com>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CPView.j>

@import "../Resources/Translator/TranslatorKnownLanguages.js"

_sharedTranslatorController = nil;

// TODO : tester avec les alertes
// TODO : gérer également les problèmes avec les text fields (ex : l'alerte en NL qd démarrage OK)

// TODO : faire une méthode qui fournit un menu "Langue" (indiqué dans la langue du navigateur) avec le logo spécial, à inclure, par exemple, sur un panneau de login
// TODO : faire des vérifications de double déclaration de langues (supported, known)
// TODO : fix : recalcul des positions pour toolbar

// TODO : faire un outil qui crée un fichier .xstrings à traduire
// TODO : faire un outil qui compile un fichier .strings en .xstring (de mémoire une commande putil)


@implementation TranslatorController : CPObject
{
    CPString        _currentLanguage;       // the current language to use
    CPDictionary    _supportedLanguages;    // the languages supported by the application (loaded from Info.plist)
    CPDictionary    _knownLanguages;        // the languages known by Translator
    CPString        _defaultLanguage;       // the language in which the application is written (loaded from Info.plist)
    CPDictionary    _languageDictionaries;  // the various dictionaries loaded from Resources/xx.xstrings
    CPDictionary    _currentDictionary;     // the dictionary for the current language
    BOOL            _mustTranslate;         // just to avoid testing again and again (_currentLanguage == _defaultLanguage)

    CPMutableArray  _viewsToTranslate       @accessors(readonly, property=viewsToTranslate);
    CPMutableArray  _tableViewsToTranslate  @accessors(readonly, property=viewsToTranslate); // list of all tableViews to translate
    CPMenu          _menuToTranslate        @accessors(property=menuToTranslate);            // the menubar to translate
    CPToolbar       _toolbarToTranslate     @accessors(property=toolbarToTranslate);         // the toolbar to translate
}

+ (TranslatorController)sharedTranslator
{
    if (!_sharedTranslatorController)
        
        _sharedTranslatorController = [[TranslatorController alloc] init];
    
    return _sharedTranslatorController;
}

#pragma mark -
#pragma mark Initialization

- (TranslatorController)init
{
    self = [super init];
    
    if (self)
    {
        // We load the _defaultLanguage from the Info.plist
        
        _defaultLanguage = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"TranslatorDefaultLanguage"];
        
        // We load the _knowLanguages dictionary
        
        var nbKnownLanguages = [TRANSLATOR_KNOWN_LANGUAGES_ARRAY count];
        
        _knownLanguages = [CPDictionary dictionary];
        
        for (var i = 0; i < nbKnownLanguages; i++)
        {
            var item = [TRANSLATOR_KNOWN_LANGUAGES_ARRAY objectAtIndex:i];
            
            [_knownLanguages setValue:[item objectAtIndex:1] forKey:[item objectAtIndex:0]];
        }

        // We load the _supportedLanguages dictionary from Info.plist
    
        _supportedLanguages = [CPDictionary dictionary];
        
        var supportedLanguages = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"TranslatorSupportedLanguages"];
        var nbSupportedLanguages = [supportedLanguages count];
        var item;
        var itemValue;
        
        for (var i = 0; i < nbSupportedLanguages; i++)
        {
            item = [supportedLanguages objectAtIndex:i];
            itemValue = [_knownLanguages valueForKey:item];
            
            if (!itemValue)
                
                CPLog.error("Translator [init] : You try to set \"" + item + "\" as a supported language but, and I'm sorry for this, I don't know this language...");
            
            [_supportedLanguages setValue:[_knownLanguages valueForKey:item] forKey:item];
        }
        
        // By default, _currentLanguage is set to _defaultLanguage

        _currentLanguage = _defaultLanguage;
        
        _mustTranslate = NO;
        
        // For now, simply initialize the _languageDictionaries
        
        _languageDictionaries = [CPDictionary dictionary];
        
        _currentDictionary  = nil;
        
        _viewsToTranslate      = [[CPMutableArray alloc] init];
        _tableViewsToTranslate = [[CPMutableArray alloc] init];
        _menuToTranslate       = nil;
        _toolbarToTranslate    = nil;
    }
    
    return self;
}


#pragma mark -
#pragma mark Translation

- (CPString)translate:(CPString)aKey
{
    // If the current language is the default language (that is the language in which the application UI is written),
    // no translation is required, so just return the key.

    if (! _mustTranslate) return aKey;
    
    // OK, now search in the current language dictionary for the key
    
    var translation = [_currentDictionary valueForKey:aKey];
    
    // If found, simply return it ; if not, return the key between brackets to indicate a missing dictionary entry
    
    return (translation) ? translation : "["+aKey+"]";
}

#pragma mark -
#pragma mark Public Tools

- (BOOL)setLanguage:(CPString)aKey
{
    // If the new language is the same than the current one, just return right now !
    
    if (aKey == _currentLanguage) return YES;
    
    if ([_supportedLanguages valueForKey:aKey])
    {
        [self _setLanguage:aKey];
        
        // As we've changed the language, we have to force redisplay of the whole UI.
        
        [self _updateViews:_viewsToTranslate];
        [self _updateViews:_tableViewsToTranslate];
        
        [_menuToTranslate    translatorForceRefresh];
        [_toolbarToTranslate translatorForceRefresh];
        
        return YES;
    }
    
    // Oups ! Not a supported language...
    
    CPLog.error("Translator [setLanguage] : I'm confused but you try to set language to \"" + aKey + "\", which is not a supported language...");
    
    return NO;
}

- (CPString)currentLanguage
{
    return _currentLanguage;
}

- (CPString)currentLanguageName
{
    return [_supportedLanguages valueForKey:_currentLanguage];
}

- (BOOL)setLanguageWithName:(CPString)aLanguage
{
    var key = [self languageForLanguageName:aLanguage];
    
    if (key)

        return [self setLanguage:key];
    
    // Oups ! Not a supported language...
    
    CPLog.error("Translator [setLanguageWithName] : I'm affraid I can't set language to \"" + aLanguage + "\" because I don't find it in the supported languages...");

    return NO;
}

- (CPArray)supportedLanguages
{
    return [_supportedLanguages allKeys];
}

- (CPArray)supportedLanguagesNames
{
    return [[_supportedLanguages allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (CPString)languageForLanguageName:(CPString)aName
{
    return [[_supportedLanguages allKeysForObject:aName] firstObject];
}

- (CPString)languageNameForLanguage:(CPString)aKey
{
    return [_supportedLanguages valueForKey:aKey];
}

// --------

- (void)addViewToViewsToTranslate:(CPView)aView
{
    [_viewsToTranslate addObject:aView];
}

- (void)addViewsToViewsToTranslate:(CPArray)someViews
{
    [_viewsToTranslate addObjectsFromArray:someViews];
}

- (void)addTableViewToTranslate:(CPTableView)aTableView
{
    [_tableViewsToTranslate addObject:aTableView];
}

- (void)removeTableViewToTranslate:(CPTableView)aTableView
{
    [_tableViewsToTranslate removeObject:aTableView];
}

// --------

- (CPString)browserLanguage
{
    var userLang = (navigator.language) ? navigator.language : navigator.userLanguage;
    
    return userLang.substring(0,2)
}

- (CPString)defaultLanguage
{
    return _defaultLanguage;
}

- (BOOL)canSupportLanguage:(CPString)aKey
{
    return ([_supportedLanguages valueForKey:aKey]);
}

- (CPString)tryToSetLanguage:(CPString)preferedLanguage
 ifNeededUseUrlArgumentNamed:(CPString)urlArgumentName
  ifNeededUseBrowserLanguage:(BOOL)canTryBrowserLanguage
{
    // Use this method to set the initial language for your application
    //
    // What this tries to do is :
    //
    // 1. If preferedLanguage is not nil and is supported, use it
    // 2. If urlArgumentName is not nil and is available in the URL arguments, and is valid, use it
    // 3. If canTryBrowserLanguage is YES, use the browser language
    // 4. If nothing above worked, just use the default language as specified in the Info.plist
    //
    // What I personally do is to first try to load user's preferences and if it's OK, pass it as the preferedLanguage argument.
    // Then, as my app can be integrated behind a single sign on portal, I check for the argument named "userlang"
    //
    // For example :
    //
    //      [theTranslator tryToSetLanguage:(preferencesLoaded ? [preferencesController valueForKey:@"langue"] : nil)
    //          ifNeededUseUrlArgumentNamed:@"userlang"
    //           ifNeededUseBrowserLanguage:YES];
    //
    // If you have a login panel, you can include a language menu and keep the user's choice as preferedLanguage.
    //
    // The method returns the language that has been set.
    
    var theLanguage = nil;
    var tmpLanguage;
    
    if ((preferedLanguage) && [self canSupportLanguage:preferedLanguage])
        
        theLanguage = preferedLanguage;
    
    else if ((urlArgumentName) && (tmpLanguage = [self _languageFromUrlArgumentNamed:urlArgumentName]) && [self canSupportLanguage:tmpLanguage])
        
        theLanguage = tmpLanguage;
    
    else if (canTryBrowserLanguage && (tmpLanguage = [self browserLanguage]) && [self canSupportLanguage:tmpLanguage])
        
        theLanguage = tmpLanguage;
    
    else
        
        theLanguage = [self defaultLanguage];

    // Attention : we can't call setLanguage because the UI is not yet ready until the end of the awakeFromCib, and,
    // of course, you have to call tryToSetLanguage before the end of awakeFromCib... (or your UI will first appear
    // in one language then switch to another. So, we simply call _setLanguage which just don't try to update the UI
    // and the world then turn as it should...
    
    [self _setLanguage:theLanguage];
    
    return theLanguage;
}


#pragma mark -
#pragma mark Private Tools

- (void)_updateViews:(CPArray)views
{
    for (var i = 0, nb = [views count]; i < nb; i++)
        
        [[views objectAtIndex:i] translatorForceRefresh];
}

- (void)_setLanguage:(CPString)aKey
{
    _currentLanguage = aKey;
    
    _mustTranslate = (_currentLanguage != _defaultLanguage);
    
    _currentDictionary = (_mustTranslate) ? [self _dictionaryForLanguage:_currentLanguage] : nil;
    
    // I don't know why but it seems that TableViews are initialized very early, so we have to force update them.
    
    [self _updateViews:_viewsToTranslate];
    [self _updateViews:_tableViewsToTranslate];
}

- (CPString)_languageFromUrlArgumentNamed:(CPString)urlArgumentName
{
    if (!urlArgumentName) return nil;
    
    var sharedApplication = [CPApplication sharedApplication];
    
    var argumentsDictionary = [sharedApplication namedArguments];
    
    return [argumentsDictionary valueForKey:urlArgumentName];
}

- (CPDictionary)_dictionaryForLanguage:(CPString)aKey
{
    // Just to be sure, in case of a silly direct call of this method, we check if aKey
    // is a supported language...
    
    if (![_supportedLanguages valueForKey:aKey])
    {
        CPLog.error("Translator [_dictionaryForLanguage] : Well, hum... It should not happen but you try to find the dictionary for \"" + aKey + "\" but this is not a supported language...");
        
        return nil;
    }
    
    // Now, check if we already have the dictionary in _languageDictionaries
    
    var foundDictionary = [_languageDictionaries valueForKey:aKey];
    
    if (foundDictionary)
    {
        // Yes ! So we just have to return it. Not so difficult to do...
        
        return foundDictionary;
    }
    
    // No... Well, we have to load it from the corresponding .xstring file
    
    var request  = [CPURLRequest requestWithURL:@"Resources/Translator/" + aKey + ".xstrings"];
    var response = [CPURLConnection sendSynchronousRequest:request returningResponse:response];
    
    if (!response)
    {
        // Oups ! Something bad happened ! We didn't successfully load the language file !
        
        CPLog.error("Translator [_dictionaryForLanguage] : Oops ! Something bad happened... I was unable to load the language dictionary from URL " + [request URL] + "... Application will certainly abort complaining about null problems, blah blah blah... Or display may be somewhat \"special\"...");
        
        return nil;
    }
    
    var newDictionary = [CPPropertyListSerialization propertyListFromData:response format:nil];
    
    // We store the dictionary in _languageDictionaries
    
    [_languageDictionaries setValue:newDictionary forKey:aKey];
    
    // And we return it
    
    return newDictionary;
}

@end

