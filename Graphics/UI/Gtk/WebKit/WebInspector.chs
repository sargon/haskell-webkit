{-# LANGUAGE ForeignFunctionInterface #-}

{# context lib="libwebkit" prefix="webkit_" #}

module Graphics.UI.Gtk.WebKit.WebInspector
    ( WebInspector

    -- , webInspectorClose -- new in webkit 1.1.17
    -- , webInspectorShow  -- new in webkit 1.1.17
    -- , webInspectorInspectCoordinates -- new in webkit 1.1.17
    , webInspectorGetWebView
    , webInspectorGetInspectedUri


    ) where

#include <webkit/webkitwebinspector.h>

import Foreign.C
import GHC.Ptr
import System.Glib.FFI

import Control.Monad

import Graphics.UI.Gtk
    ( makeNewObject
    )

{#import Graphics.UI.Gtk.WebKit.General.Types#}
    ( WebInspector
    , WebView

    , mkWebInspector
    , withWebInspector
    , mkWebView
    )

webInspectorGetInspectedUri :: WebInspector -> IO String
webInspectorGetInspectedUri inspector =
    withWebInspector inspector $ \ptr ->
        {#call web_inspector_get_inspected_uri#} ptr >>= peekCString

webInspectorGetWebView :: WebInspector -> IO WebView
webInspectorGetWebView inspector = 
    withWebInspector inspector $ \ptr ->
        makeNewObject mkWebView $ 
            {#call web_inspector_get_web_view#} ptr 

{- new in webkit 1.1.17
webInspectorInspectCoordinates :: WebInspector -> Double -> Double -> IO ()
webInspectorInspectCoordinates inspector x y =
    withWebInspector inspector $ \ptr ->
        {#call web_inspector_inspect_coordinates#} ptr (toRational x) (toRational y)

webInspectorShow :: WebInspector -> IO ()
webInspectorShow inspector =
    withWebInspector inspector $ \ptr ->
        {#call  web_inspector_show#} ptr

webInspectorClose :: WebInspector -> IO ()
webInspectorClose inspector =
    withWebInspector inspector $ \ptr ->
        {#call  web_inspector_close#} ptr
-} 

{- TODO Propertys
  "javascript-profiling-enabled" gboolean              : Read / Write
  "timeline-profiling-enabled" gboolean              : Read / Write -- new in webkit 1.1.17
-}

{- TODO Signals 
  "attach-window"                                  : Run Last
  "close-window"                                   : Run Last
  "detach-window"                                  : Run Last
  "finished"                                       : Run Last
  "inspect-web-view"                               : Run Last
  "show-window"                                    : Run Last
-}
