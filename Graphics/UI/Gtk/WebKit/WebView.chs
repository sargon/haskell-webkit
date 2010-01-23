{-# LANGUAGE ForeignFunctionInterface #-}

{# context lib="libwebkit" prefix="webkit_" #}

{-| The central datatype of Haskell WebKit

'WebView' is the central datatype of Haskell WebKit. It is an instance of
'WidgetClass' implementing the scrolling interface which means you can embed in
a 'ScrolledWindow'. It is responsible for managing the drawing of the content,
forwarding of events. You can load any URI into the 'WebView' or any kind of
data string. With 'WebSettings' you can control various aspects of the
rendering and loading of the content. Each 'WebView' has exactly one 'WebFrame'
as main frame. A 'WebFrame' can have n children.
-}

module Graphics.UI.Gtk.WebKit.WebView
    ( WebView

    -- * Functions

    , webViewGetType

    , webViewNew

    , webViewGetTitle
    , webViewGetUri

    , webViewSetMaintainsBackForwardList
    , webViewGetBackForwardList
    , webViewGoToBackForwardItem 

    , webViewCanGoBack
    , webViewCanGoBackOrForward
    , webViewCanGoForward

    , webViewGoBack
    , webViewGoBackOrForward
    , webViewGoForward

    , webViewStopLoading
    -- , webViewOpen
    , webViewReload
    , webViewReloadBypassCache

    , webViewLoadUri
    , webViewLoadString
    , webViewLoadHtmlString
    , webViewLoadRequest 

    , webViewSearchText
    , webViewMarkTextMatches
    , webViewSetHighlightTextMatches
    , webViewUnmarkTextMatches

    , webViewGetMainFrame
    , webViewGetFocusedFrame

    , webViewExecuteScript

    , webViewCanCutClipboard
    , webViewCanCopyClipboard
    , webViewCanPasteClipboard

    , webViewCutClipboard
    , webViewCopyClipboard
    , webViewPasteClipboard

    , webViewDeleteSelection
    , webViewHasSelection
    , webViewSelectAll

    , webViewGetEditable
    , webViewSetEditable

    , webViewGetCopyTargetList
    , webViewGetPasteTargetList

    , webViewSetSettings
    , webViewGetSettings

    , webViewGetInspector

    --, webViewGetWindowFeatures

    , webViewCanShowMimeType

    , webViewGetTransparent
    , webViewSetTransparent

    , webViewGetZoomLevel
    , webViewSetZoomLevel

    , webViewZoomIn
    , webViewZoomOut

    , webViewGetFullContentZoom
    , webViewSetFullContentZoom

    --, getDefaultSession

    , webViewGetEncoding

    , webViewSetCustomEncoding
    , webViewGetCustomEncoding

    --, webViewMoveCursor

    , webViewGetLoadStatus
    , webViewGetProgress

    --, webViewUndo
    --, webViewCanUndo

    --, webViewRedo
    --, webViewCanRedo

    --, webViewSetViewSourceMode
    --, webViewGetViewSourceMode

    --, webViewGetHitTestResult

    -- * Properties

    --, webViewGetCopyTargetList

    --, webViewGetCustomEncoding
    --, webViewSetCustomEncoding

    --, webViewGetEditable
    --, webViewSetEditable

    --, webViewGetEncoding

    --, webViewGetFullContentZoom
    --, webViewSetFullContentZoom

    , webViewGetIconUri

    --, webViewGetLoadStatus

    --, webViewGetPasteTargetList

    --, webViewGetProgress

    --, webViewGetSettings
    --, webViewSetSettings

    --, webViewGetTitle

    --, webViewGetTransparent
    --, webViewSetTransparent

    --, webViewGetUri

    , webViewGetWindowFeatures
    , webViewSetWindowFeatures

    --, webViewGetZoomLevel
    --, webViewSetZoomLevel

    -- * Signals

    , onWebViewCopyClipboard
    , afterWebViewCopyClipboard

    , onWebViewCutClipboard
    , afterWebViewCutClipboard

    , onWebViewHoveringOverLink
    , afterWebViewHoveringOverLink

    , onWebViewIconLoaded
    , afterWebViewIconLoaded

    -- , onWebViewLoadCommitted
    -- , afterWebViewLoadCommitted

    -- , onWebViewLoadFinished
    -- , afterWebViewLoadFinished

    -- , onWebViewLoadStarted
    -- , afterWebViewLoadStarted

    , onWebViewPasteClipboard
    , afterWebViewPasteClipboard

    , onWebViewSelectAll
    , afterWebViewSelectAll

    , onWebViewSelectionChanged
    , afterWebViewSelectionChanged

    , onWebViewStatusbarTextChanged
    , afterWebViewStatusbarTextChanged

    -- , onWebViewTitleChanged
    -- , afterWebViewTitleChanged
    ) where
 
#include <webkit/webkitwebview.h>

import Foreign.C
import GHC.Ptr
import System.Glib.FFI

import System.Glib.GType
import System.Glib.Properties

import Control.Monad

import Graphics.UI.Gtk
    ( makeNewObject
    )

import Graphics.UI.Gtk.Signals
import Graphics.UI.Gtk.General.DNDTypes

{#import Graphics.UI.Gtk.WebKit.General.Types#}
    ( NetworkRequest
    , WebFrame
    , WebView
    , WebSettings
    , WebBackForwardList
    , WebHistoryItem
    , WebInspector

    , withNetworkRequest
    , withWebFrame
    , mkWebFrame
    , withWebView
    , mkWebView
    , withWebSettings
    , mkWebSettings
    , withWebBackForwardList 
    , mkWebBackForwardList
    , withWebHistoryItem
    , mkWebHistoryItem
    , withWebView
    , withWebSettings
    , mkWebInspector
    )

{#import Graphics.UI.Gtk.WebKit.General.Enums#}
    ( LoadStatus (..)
    )

{#import Graphics.UI.Gtk.WebKit.WebWindowFeatures#}
    ( WebWindowFeatures
    , webWindowFeaturesGetType
    )

webViewGetType :: IO GType
webViewGetType =
    {#call web_view_get_type#}

webViewNew :: IO WebView
webViewNew = do
    ptr <- {#call web_view_new#}
    let ptr' = castPtr ptr
    makeNewObject mkWebView (return ptr')

webViewGetTitle :: WebView -> IO (Maybe String)
webViewGetTitle web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_get_title#} ptr
            >>= maybePeek peekCString

webViewGetUri :: WebView -> IO (Maybe String)
webViewGetUri web_view = do
    withWebView web_view $ \ptr ->
        {#call web_view_get_uri#} ptr
            >>= maybePeek peekCString

webViewSetMaintainsBackForwardList :: WebView -> Bool -> IO ()
webViewSetMaintainsBackForwardList web_view flag =
    withWebView web_view $ \ptr ->
        {#call web_view_set_maintains_back_forward_list#}
            ptr $ fromBool flag

-- | Returns the 'WebBackForwardList' for the given 'WebView'.
webViewGetBackForwardList :: WebView               -- ^ the 'WebView'
                          -> IO WebBackForwardList -- ^ the 'WebBackForwardList'
webViewGetBackForwardList view =
    withWebView view $ \ptr ->
        makeNewObject mkWebBackForwardList $
            {#call web_view_get_back_forward_list#} ptr

webViewGoToBackForwardItem :: WebView -> WebHistoryItem -> IO Bool
webViewGoToBackForwardItem view item =
    withWebView view $ \ptr ->
        withWebHistoryItem item $ \iptr ->
            liftM toBool $
                {#call web_view_go_to_back_forward_item#} ptr iptr 
 
-- | Determines whether the given 'WebView' has a previous history item.
webViewCanGoBack :: WebView -- ^ lookup history for this 'WebView'
                 -> IO Bool -- ^ 'True' if able to move back, 'False' otherwise
webViewCanGoBack web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_can_go_back#} ptr

{- | Determines whether the given 'WebView' has a history item a given number
     of steps away. Negative values represent steps backward while positive
     values represent steps forward.
-}
webViewCanGoBackOrForward :: WebView -- ^ lookup history for this 'WebView'
                          -> Int     -- ^ the number of steps 
                          -> IO Bool -- ^ 'True' if able to move back or forward
                                     --   the given number of steps, 'False'
                                     --   otherwise 
webViewCanGoBackOrForward web_view steps = do
    withWebView web_view $ \ptr ->
        liftM toBool $
            {#call web_view_can_go_back_or_forward#}
                ptr (fromIntegral steps)

-- | Determines whether the given 'WebView' has a next history item.
webViewCanGoForward :: WebView -- ^ lookup history for this 'WebView'
                    -> IO Bool -- ^ 'True' if able to move forward, 'False'
                               --   otherwise
webViewCanGoForward web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_can_go_forward#} ptr

-- | Loads the previous history item.
webViewGoBack :: WebView -- ^ the 'WebView' that should go back
              -> IO ()
webViewGoBack web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_go_back#} ptr

{- | Loads the history item that is the number of steps away from the current
     item. Negative values represent steps backward while positive values
     represent steps forward.
-}
webViewGoBackOrForward :: WebView -- ^ the 'WebView' that should go back or
                                  --   forward
                       -> Int     -- ^ number of steps
                       -> IO ()
webViewGoBackOrForward web_view steps =
    withWebView web_view $ \ptr ->
        {#call web_view_go_back_or_forward#} ptr (fromIntegral steps)

-- | Loads the next history item.
webViewGoForward :: WebView -- ^ the 'WebView' that should go forward
                 -> IO ()
webViewGoForward web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_go_forward#} ptr

webViewStopLoading :: WebView -> IO ()
webViewStopLoading web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_stop_loading#} ptr

{- DEPRECATED since 1.1.1
webViewOpen :: WebView -> String -> IO ()
webViewOpen web_view uri = do
    withCString uri $ \c_uri ->
        withWebView web_view $ \ptr ->
            {#call web_view_open#} ptr c_uri
-}

webViewReload :: WebView -> IO ()
webViewReload web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_reload#} ptr

webViewReloadBypassCache :: WebView -> IO ()
webViewReloadBypassCache web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_reload_bypass_cache#} ptr

-- | Requests loading of the specified URI string.
webViewLoadUri :: WebView -- ^ load in this 'WebView'
               -> String  -- ^ URI to load
               -> IO ()
webViewLoadUri web_view uri = do
    withCString uri $ \c_uri ->
        withWebView web_view $ \ptr ->
            {#call web_view_load_uri#} ptr c_uri

webViewLoadString :: WebView -> String -> String -> String -> String -> IO ()
webViewLoadString web_view content mime_type encoding base_uri = do
    withCString content $ \c_content ->
        withCString mime_type $ \c_mime_type ->
            withCString encoding $ \c_encoding ->
                withCString base_uri $ \c_base_uri ->
                    withWebView web_view $ \ptr ->
                        {#call web_view_load_string#}
                            ptr c_content c_mime_type c_encoding c_base_uri

webViewLoadHtmlString :: WebView -> String -> String -> IO ()
webViewLoadHtmlString web_view content base_uri = do
    withCString content $ \c_content ->
        withCString base_uri $ \c_base_uri ->
            withWebView web_view $ \ptr ->
                {#call web_view_load_html_string#}
                    ptr c_content c_base_uri

{- | Requests loading of the specified asynchronous client 'NetworkRequest'.

     Creates a provisional data source that will transition to a committed
     data source once any data has been received. Use 'webViewStopLoading'
     to stop the load.
-}
webViewLoadRequest :: WebView        -- ^ load in this 'WebView'
                   -> NetworkRequest -- ^ 'NetworkRequest' to load
                   -> IO ()
webViewLoadRequest web_view request =
    withWebView web_view $ \wv_ptr ->
        withNetworkRequest request $ \r_ptr ->
            {#call web_view_load_request#} wv_ptr r_ptr

webViewSearchText :: WebView -> String -> Bool -> Bool -> Bool -> IO Bool
webViewSearchText web_view text case_sensitive forward wrap =
    withCString text $ \c_text ->
        withWebView web_view $ \ptr ->
            liftM toBool $
                {#call web_view_search_text#}
                    ptr c_text (fromBool case_sensitive)
                    (fromBool forward) (fromBool wrap)

webViewMarkTextMatches :: WebView -> String -> Bool -> Int -> IO Int
webViewMarkTextMatches web_view string case_sensitive limit =
    withCString string $ \c_string ->
        withWebView web_view $ \ptr ->
            liftM fromIntegral $
                {#call web_view_mark_text_matches#}
                    ptr c_string (fromBool case_sensitive) (fromIntegral limit)

webViewSetHighlightTextMatches :: WebView -> Bool -> IO ()
webViewSetHighlightTextMatches web_view highlight =
    withWebView web_view $ \ptr ->
        {#call web_view_set_highlight_text_matches#} ptr $ fromBool highlight

webViewUnmarkTextMatches :: WebView -> IO ()
webViewUnmarkTextMatches web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_unmark_text_matches#} ptr

webViewGetMainFrame :: WebView -> IO WebFrame
webViewGetMainFrame web_view =
    withWebView web_view $ \ptr ->
        makeNewObject mkWebFrame $ {#call web_view_get_main_frame#} ptr

webViewGetFocusedFrame :: WebView -> IO WebFrame
webViewGetFocusedFrame web_view =
    withWebView web_view $ \ptr ->
        makeNewObject mkWebFrame $ {#call web_view_get_focused_frame#} ptr

webViewExecuteScript :: WebView -> String -> IO ()
webViewExecuteScript web_view script = do
    withCString script $ \c_script ->
        withWebView web_view $ \ptr ->
            {#call web_view_execute_script#} ptr c_script

webViewCanCutClipboard :: WebView -> IO Bool
webViewCanCutClipboard web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_can_cut_clipboard#} ptr

webViewCanCopyClipboard :: WebView -> IO Bool
webViewCanCopyClipboard web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_can_copy_clipboard#} ptr

webViewCanPasteClipboard :: WebView -> IO Bool
webViewCanPasteClipboard web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_can_paste_clipboard#} ptr

-- | Cuts the current selection inside the 'WebView' to the clipboard.
webViewCutClipboard :: WebView  -- ^ the 'WebView' to cut from
                    -> IO ()
webViewCutClipboard web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_cut_clipboard#} ptr

-- | Copies the current selection inside the 'WebView' to the clipboard.
webViewCopyClipboard :: WebView -- ^ the 'WebView' to copy from
                     -> IO ()
webViewCopyClipboard web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_copy_clipboard#} ptr

-- | Pastes the current contents of the clipboard to the 'WebView'.
webViewPasteClipboard :: WebView -- ^ the 'WebView' to paste to
                      -> IO ()
webViewPasteClipboard web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_paste_clipboard#} ptr

-- | Deletes the current selection inside the 'WebView'.
webViewDeleteSelection :: WebView -- ^ the 'WebView' to delete from
                       -> IO ()
webViewDeleteSelection web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_delete_selection#} ptr

webViewHasSelection :: WebView -> IO Bool
webViewHasSelection web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_has_selection#} ptr

webViewSelectAll :: WebView -> IO ()
webViewSelectAll web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_select_all#} ptr

{- | Returns whether the user is allowed to edit the document.

Returns 'True' if 'WebView' allows the user to edit the HTML document, 'False'
if it doesn\'t. You can change the document programmatically regardless of
this setting.
-}
webViewGetEditable :: WebView -- ^ the 'WebView'
                   -> IO Bool -- ^ indicates the editable state
webViewGetEditable web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $ {#call web_view_get_editable#} ptr

webViewSetEditable :: WebView -> Bool -> IO ()
webViewSetEditable web_view flag =
    withWebView web_view $ \ptr ->
        {#call web_view_set_editable#} ptr $ fromBool flag

-- TODO: Understand this stuff and check wether this does work as it should...
webViewGetCopyTargetList :: WebView -> IO TargetList
webViewGetCopyTargetList web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_get_copy_target_list#} ptr
            >>= mkTargetList . castPtr -- TODO: is this okay?

-- TODO: Understand this stuff and check wether this does work as it should...
webViewGetPasteTargetList :: WebView -> IO TargetList
webViewGetPasteTargetList web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_get_paste_target_list#} ptr
            >>= mkTargetList . castPtr -- TODO: is this okay?

webViewSetSettings :: WebView -> WebSettings -> IO ()
webViewSetSettings web_view settings = 
    withWebView web_view $ \vptr ->
        withWebSettings settings $ \sptr ->
            {#call web_view_set_settings#} vptr sptr

webViewGetSettings :: WebView -> IO WebSettings 
webViewGetSettings web_view =
    withWebView web_view $ \ptr ->
        makeNewObject mkWebSettings $ {#call web_view_get_settings#} ptr

webViewGetInspector :: WebView -> IO WebInspector
webViewGetInspector web_view =
    withWebView web_view $ \ptr ->
        makeNewObject mkWebInspector $ {#call web_view_get_inspector#} ptr

{- TODO
WebKitWebWindowFeatures* webkit_web_view_get_window_features (WebKitWebView *web_view);
-}

-- | This functions returns whether or not a MIME type can be displayed using
--   this view.
webViewCanShowMimeType :: WebView -- ^ the 'WebView' to check
                       -> String  -- ^ the MIME type
                       -> IO Bool -- ^ 'Bool' indicating if MIME type can be
                                  --   displayed
webViewCanShowMimeType web_view mime_type = do
    withCString mime_type $ \c_mime_type ->
        withWebView web_view $ \ptr ->
            liftM toBool $
                {#call web_view_can_show_mime_type#} ptr c_mime_type

-- | Returns whether the 'WebView' has a transparent background.
webViewGetTransparent :: WebView -- ^ the 'WebView'
                      -> IO Bool -- ^ 'False' when the 'WebView' draws a solid
                                 --   background (the default), otherwise 'True'
webViewGetTransparent web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $
            {#call web_view_get_transparent#} ptr

webViewSetTransparent :: WebView -> Bool -> IO ()
webViewSetTransparent web_view flag =
    withWebView web_view $ \ptr ->
        {#call web_view_set_transparent#} ptr $
            fromBool flag

{- | Returns the zoom level of the given 'WebView', i.e. the factor by which
     elements in the page are scaled with respect to their original size. If
     the "full-content-zoom" property is set to 'False' (the default) the zoom
     level changes the text size, or if 'True', scales all elements in the
     page.
-}
webViewGetZoomLevel :: WebView  -- ^ the 'WebView'
                    -> IO Float -- ^ the zoom level
webViewGetZoomLevel web_view =
    withWebView web_view $ \ptr ->
        liftM realToFrac $
            {#call web_view_get_zoom_level#} ptr

webViewSetZoomLevel :: WebView -> Float -> IO ()
webViewSetZoomLevel web_view zoom_level =
    withWebView web_view $ \ptr ->
        {#call web_view_set_zoom_level#} ptr $
            realToFrac zoom_level

webViewZoomIn :: WebView -> IO ()
webViewZoomIn web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_zoom_in#} ptr

webViewZoomOut :: WebView -> IO ()
webViewZoomOut web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_zoom_out#} ptr

webViewGetFullContentZoom :: WebView -> IO Bool
webViewGetFullContentZoom web_view = do
    withWebView web_view $ \ptr ->
        liftM toBool $
            {#call web_view_get_full_content_zoom#} ptr

webViewSetFullContentZoom :: WebView -> Bool -> IO ()
webViewSetFullContentZoom web_view full_content_zoom =
    withWebView web_view $ \ptr ->
        {#call web_view_set_full_content_zoom#} ptr $
            fromBool full_content_zoom

{- TODO
SoupSession* webkit_get_default_session (void);
-}

webViewGetEncoding :: WebView -> IO (Maybe String)
webViewGetEncoding web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_get_encoding#} ptr
            >>= maybePeek peekCString

webViewSetCustomEncoding :: WebView -> String -> IO ()
webViewSetCustomEncoding web_view encoding = do
    withCString encoding $ \c_encoding ->
        withWebView web_view $ \ptr ->
            {#call web_view_set_custom_encoding#} ptr c_encoding

-- | Returns the current encoding of the 'WebView', not the default-encoding
--   of 'WebSettings'.
webViewGetCustomEncoding :: WebView           -- ^ the 'WebView'
                         -> IO (Maybe String) -- ^ 'Just' encoding if set,
                                              --   otherwise 'Nothin'
webViewGetCustomEncoding web_view =
    withWebView web_view $ \ptr ->
        {#call web_view_get_custom_encoding#} ptr
            >>= maybePeek peekCString

{- TODO
void webkit_web_view_move_cursor (WebKitWebView * webView, GtkMovementStep step, gint count);
-}

webViewGetLoadStatus :: WebView -> IO LoadStatus
webViewGetLoadStatus web_view =
    withWebView web_view $ \ptr ->
        liftM (toEnum . fromIntegral) $
            {#call web_view_get_load_status#} ptr

webViewGetProgress :: WebView -> IO Double
webViewGetProgress web_view =
    withWebView web_view $ \ptr ->
        liftM realToFrac $
            {#call web_view_get_progress#} ptr

{- TODO
void webkit_web_view_undo (WebKitWebView *webView);
gboolean webkit_web_view_can_undo (WebKitWebView *webView);
void webkit_web_view_redo (WebKitWebView *webView);
gboolean webkit_web_view_can_redo (WebKitWebView *webView);
void webkit_web_view_set_view_source_mode (WebKitWebView *web_view, gboolean view_source_mode);
gboolean webkit_web_view_get_view_source_mode (WebKitWebView *web_view);
WebKitHitTestResult* webkit_web_view_get_hit_test_result (WebKitWebView *webView, GdkEventButton *event);
-}

-- Properties ------------------------------------------------------------------

{- Not needed...?
"copy-target-list" GtkTargetList* : Read
"custom-encoding" gchar* : Read / Write
"editable" gboolean : Read / Write
"encoding" gchar* : Read
"full-content-zoom" gboolean : Read / Write
-}

webViewGetIconUri :: WebView -> IO String
webViewGetIconUri =
    objectGetPropertyString
        "icon-uri"

{- Not needed...?
"load-status" WebKitLoadStatus : Read
"paste-target-list" GtkTargetList* : Read
"progress" gdouble : Read
"settings" WebKitWebSettings* : Read / Write
"title" gchar* : Read
"transparent" gboolean : Read / Write
"uri" gchar* : Read
-}

webViewSetWindowFeatures :: WebView -> WebWindowFeatures -> IO ()
webViewSetWindowFeatures web_view web_window_features = do
    wwft <- webWindowFeaturesGetType
    objectSetPropertyGObject wwft "window-features" web_view web_window_features

webViewGetWindowFeatures :: WebView -> IO WebWindowFeatures
webViewGetWindowFeatures web_view = do
    wwft <- webWindowFeaturesGetType
    objectGetPropertyGObject wwft "window-features" web_view

{- Not needed...?
"zoom-level" gfloat : Read / Write
-}

-- Signals ---------------------------------------------------------------------

{- TODO
"close-web-view" : gboolean user_function (WebKitWebView *web_view, gpointer user_data) : Run Last
"console-message" : gboolean user_function (WebKitWebView *web_view, gchar *message, gint line, gchar *source_id, gpointer user_data) : Run Last / Action
-}

onWebViewCopyClipboard, afterWebViewCopyClipboard ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewCopyClipboard =
    connect_NONE__NONE "copy-clipboard" False
afterWebViewCopyClipboard =
    connect_NONE__NONE "copy-clipboard" True

{- TODO"create-plugin-widget" : GtkWidget* user_function (WebKitWebView *web_view, gchar *mime_type, gchar *uri, GHashTable *param, gpointer user_data) : Run Last / Action
"create-web-view" : WebKitWebView* user_function (WebKitWebView *web_view, WebKitWebFrame *frame, gpointer user_data) : Run Last / Action
-}

onWebViewCutClipboard, afterWebViewCutClipboard ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewCutClipboard =
    connect_NONE__NONE "cut-clipboard" False
afterWebViewCutClipboard =
    connect_NONE__NONE "cut-clipboard" True

{- TODO
"database-quota-exceeded" : void user_function (WebKitWebView *web_view, GObject *frame, GObject *database, gpointer user_data) : Run Last / Action
"download-requested" : gboolean user_function (WebKitWebView *web_view, GObject *download, gpointer user_data) : Run Last
-}

onWebViewHoveringOverLink, afterWebViewHoveringOverLink ::
    WebView -> (String -> String -> IO ()) -> IO (ConnectId WebView)
onWebViewHoveringOverLink =
    connect_STRING_STRING__NONE "hovering-over-link" False
afterWebViewHoveringOverLink =
    connect_STRING_STRING__NONE "hovering-over-link" True

onWebViewIconLoaded, afterWebViewIconLoaded ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewIconLoaded =
    connect_NONE__NONE "icon-loaded" False
afterWebViewIconLoaded =
    connect_NONE__NONE "icon-loaded" True

{- DEPRECATED
onWebViewLoadCommitted, afterWebViewLoadCommitted ::
    WebView -> (WebFrame -> IO ()) -> IO (ConnectId WebView)
onWebViewLoadCommitted =
    connect_OBJECT__NONE "load-committed" False
afterWebViewLoadCommitted =
    connect_OBJECT__NONE "load-committed" True
-}

{- TODO
"load-error" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *web_frame, gchar *uri, gpointer web_error, gpointer user_data) : Run Last
-}

{- DEPRECATED
onWebViewLoadFinished, afterWebViewLoadFinished ::
    WebView -> (WebFrame -> IO ()) -> IO (ConnectId WebView)
onWebViewLoadFinished =
    connect_OBJECT__NONE "load-finished" False
afterWebViewLoadFinished =
    connect_OBJECT__NONE "load-finished" True
-}

{- DEPRECATED ?TODO?
"load-progress-changed" : void user_function (WebKitWebView *web_view, gint progress, gpointer user_data) : Run Last / Action
-}

{- DEPRECATED
onWebViewLoadStarted, afterWebViewLoadStarted ::
    WebView -> (WebFrame -> IO ()) -> IO (ConnectId WebView)
onWebViewLoadStarted =
    connect_OBJECT__NONE "load-started" False
afterWebViewLoadStarted =
    connect_OBJECT__NONE "load-started" True
-}

{- TODO
"mime-type-policy-decision-requested" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, WebKitNetworkRequest *request, gchar *mimetype, WebKitWebPolicyDecision *policy_decision, gpointer user_data) : Run Last
"move-cursor" : gboolean user_function (WebKitWebView *web_view, GtkMovementStep step, gint count, gpointer user_data) : Run Last / Action
"navigation-policy-decision-requested" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, WebKitNetworkRequest *request, WebKitWebNavigationAction *navigation_action, WebKitWebPolicyDecision *policy_decision, gpointer user_data) : Run Last
-}

{- DEPRECATED
"navigation-requested" : gint user_function (WebKitWebView *webkitwebview, GObject *arg1, GObject *arg2, gpointer user_data) : Run Last / Action
-}

{- TODO
"new-window-policy-decision-requested" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, WebKitNetworkRequest *request, WebKitWebNavigationAction *navigation_action, WebKitWebPolicyDecision *policy_decision, gpointer user_data) : Run Last
-}

onWebViewPasteClipboard, afterWebViewPasteClipboard ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewPasteClipboard =
    connect_NONE__NONE "paste-clipboard" False
afterWebViewPasteClipboard =
    connect_NONE__NONE "paste-clipboard" True

{- TODO
"populate-popup" : void user_function (WebKitWebView *web_view, GtkMenu *menu, gpointer user_data) : Run Last / Action
"print-requested" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *web_frame, gpointer user_data) : Run Last
"redo" : void user_function (WebKitWebView *web_view, gpointer user_data) : Run Last / Action
"resource-request-starting" : void user_function (WebKitWebView *web_view, WebKitWebFrame *web_frame, WebKitWebResource *web_resource, WebKitNetworkRequest *request, WebKitNetworkResponse *response, gpointer user_data) : Run Last / Action
"script-alert" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, gchar *message, gpointer user_data) : Run Last / Action
"script-confirm" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, gchar *message, gboolean confirmed, gpointer user_data) : Run Last / Action
"script-prompt" : gboolean user_function (WebKitWebView *web_view, WebKitWebFrame *frame, gchar *message, gchar *default, gpointer text, gpointer user_data) : Run Last / Action
-}

onWebViewSelectAll, afterWebViewSelectAll ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewSelectAll =
    connect_NONE__NONE "select-all" False
afterWebViewSelectAll =
    connect_NONE__NONE "select-all" True

onWebViewSelectionChanged, afterWebViewSelectionChanged ::
    WebView -> IO () -> IO (ConnectId WebView)
onWebViewSelectionChanged =
    connect_NONE__NONE "selection-changed" False
afterWebViewSelectionChanged =
    connect_NONE__NONE "selection-changed" True

{- TODO
"set-scroll-adjustments" : void user_function (WebKitWebView *webkitwebview, GtkAdjustment *arg1, GtkAdjustment *arg2, gpointer user_data) : Run Last / Action
-}

onWebViewStatusbarTextChanged, afterWebViewStatusbarTextChanged ::
    WebView -> (String -> IO ()) -> IO (ConnectId WebView)
onWebViewStatusbarTextChanged =
    connect_STRING__NONE "status-bar-text-changed" False
afterWebViewStatusbarTextChanged =
    connect_STRING__NONE "status-bar-text-changed" True

{- DEPRECATED
onWebViewTitleChanged, afterWebViewTitleChanged ::
    WebView -> (WebFrame -> String -> IO ()) -> IO (ConnectId WebView)
onWebViewTitleChanged =
    connect_OBJECT_STRING__NONE "title-changed" False
afterWebViewTitleChanged =
    connect_OBJECT_STRING__NONE "title-changed" True
-}

{- TODO
"undo" : void user_function (WebKitWebView *web_view, gpointer user_data) : Run Last / Action
"web-view-ready" : gboolean user_function (WebKitWebView *web_view, gpointer user_data) : Run Last
"window-object-cleared" : void user_function (WebKitWebView *web_view, WebKitWebFrame *frame, gpointer context, gpointer arg3, gpointer user_data) : Run Last / Action
-}

