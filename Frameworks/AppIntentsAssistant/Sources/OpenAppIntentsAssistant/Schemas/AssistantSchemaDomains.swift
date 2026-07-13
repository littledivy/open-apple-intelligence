import Foundation

// MARK: - Assistant schema domain namespaces (generated to mirror the spec)
//
// Each domain (system, mail, photos, files, ...) exposes a selector on
// `AssistantSchemas.Intent/Entity/Enum` plus the member schemas within it, e.g.
//   .files.createFolder   ->  AssistantSchemas.IntentSchema("CreateFolderIntent")
// Identifiers are copied verbatim from AppIntents.swiftinterface.

// MARK: Assistant · Intent
public extension AssistantSchemas {
    protocol AssistantIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.AssistantIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var assistant: some AssistantSchemas.AssistantIntent { AssistantSchemas.IntentSchema("assistant") }
}
public extension AssistantSchemas.AssistantIntent {
    var activate: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ActivateAssistantIntent") }
}

// MARK: Books · Intent
public extension AssistantSchemas {
    protocol BooksIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.BooksIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var books: some AssistantSchemas.BooksIntent { AssistantSchemas.IntentSchema("books") }
}
public extension AssistantSchemas.BooksIntent {
    var openBook: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenBookIntent") }
    var playAudiobook: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("PlayAudiobookIntent") }
    var navigatePage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("NavigateBookPageIntent") }
    var updateFontSize: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateBookFontSizeIntent") }
    var updateLineSpacing: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateBookLineSpacingIntent") }
    var updateCharacterSpacing: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateCharacterSpacingIntent") }
    var updateWordSpacing: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateWordSpacingIntent") }
    var updateSettings: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateBookSettingsIntent") }
    var search: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SearchLibraryIntent") }
}

// MARK: Books · Entity
public extension AssistantSchemas {
    protocol BooksEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.BooksEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var books: some AssistantSchemas.BooksEntity { AssistantSchemas.EntitySchema("books") }
}
public extension AssistantSchemas.BooksEntity {
    var book: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("BookEntity") }
    var audiobook: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("AudiobookEntity") }
    var settings: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("BookSettingsEntity") }
}

// MARK: Books · Enum
public extension AssistantSchemas {
    protocol BooksEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.BooksEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var books: some AssistantSchemas.BooksEnum { AssistantSchemas.EnumSchema("books") }
}
public extension AssistantSchemas.BooksEnum {
    var contentType: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookContentType") }
    var font: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookFont") }
    var fontSize: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookFontSize") }
    var navigationDirection: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookNavigationDirection") }
    var relativeFontChange: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookRelativeFontChange") }
    var relativeCharacterSpacingChange: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookRelativeCharacterSpacingChange") }
    var relativeLineSpacingChange: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookRelativeLineSpacingChange") }
    var relativeWordSpacingChange: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookRelativeWordSpacingChange") }
    var theme: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookTheme") }
    var pageNavigationSetting: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("BookPageNavigationSetting") }
}

// MARK: Browser · Intent
public extension AssistantSchemas {
    protocol BrowserIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.BrowserIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var browser: some AssistantSchemas.BrowserIntent { AssistantSchemas.IntentSchema("None") }
}
public extension AssistantSchemas.BrowserIntent {
    var bookmarkTab: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("BookmarkTabIntent") }
    var bookmarkURL: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("BookmarkURLIntent") }
    var openBookmark: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenBookmarkIntent") }
    var deleteBookmarks: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteBookmarksIntent") }
    var clearHistory: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ClearHistoryIntent") }
    var closeTabs: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CloseTabsIntent") }
    var createTab: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateTabIntent") }
    var openURLInTab: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("LoadURLInTabIntent") }
    var switchTab: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SwitchToTabIntent") }
    var createWindow: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateWindowIntent") }
    var closeWindows: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CloseWindowsIntent") }
    var findOnPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("FindOnPageIntent") }
    var search: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SearchWebIntent") }
}

// MARK: Browser · Entity
public extension AssistantSchemas {
    protocol BrowserEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.BrowserEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var browser: some AssistantSchemas.BrowserEntity { AssistantSchemas.EntitySchema("browser") }
}
public extension AssistantSchemas.BrowserEntity {
    var bookmark: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("BookmarkEntity") }
    var tab: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("TabEntity") }
    var window: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("WindowEntity") }
}

// MARK: Browser · Enum
public extension AssistantSchemas {
    protocol BrowserEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.BrowserEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var browser: some AssistantSchemas.BrowserEnum { AssistantSchemas.EnumSchema("browser") }
}
public extension AssistantSchemas.BrowserEnum {
    var clearHistoryTimeFrame: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("ClearHistoryTimeFrameEnum") }
}

// MARK: Camera · Intent
public extension AssistantSchemas {
    protocol CameraIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.CameraIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var camera: some AssistantSchemas.CameraIntent { AssistantSchemas.IntentSchema("camera") }
}
public extension AssistantSchemas.CameraIntent {
    var openInCaptureMode: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("NavigateToCaptureModeIntent") }
    var switchDevice: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("FlipCameraIntent") }
    var setDevice: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetActiveDeviceIntent") }
    var startCapture: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("StartCameraCaptureIntent") }
    var stopCapture: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("StopCaptureIntent") }
}

// MARK: Camera · Enum
public extension AssistantSchemas {
    protocol CameraEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.CameraEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var camera: some AssistantSchemas.CameraEnum { AssistantSchemas.EnumSchema("camera") }
}
public extension AssistantSchemas.CameraEnum {
    var captureMode: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("CaptureMode") }
    var captureDuration: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("CaptureDuration") }
    var captureDevice: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("CaptureDevice") }
}

// MARK: Files · Intent
public extension AssistantSchemas {
    protocol FilesIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.FilesIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var files: some AssistantSchemas.FilesIntent { AssistantSchemas.IntentSchema("files") }
}
public extension AssistantSchemas.FilesIntent {
    var createFolder: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateFolderIntent") }
    var openFile: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenFileIntent") }
    var deleteFiles: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteFilesIntent") }
    var renameFile: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("RenameFileIntent") }
    var moveFiles: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("MoveFilesIntent") }
}

// MARK: Files · Entity
public extension AssistantSchemas {
    protocol FilesEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.FilesEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var files: some AssistantSchemas.FilesEntity { AssistantSchemas.EntitySchema("files") }
}
public extension AssistantSchemas.FilesEntity {
    var file: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("FileEntity") }
}

// MARK: Journal · Intent
public extension AssistantSchemas {
    protocol JournalIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.JournalIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var journal: some AssistantSchemas.JournalIntent { AssistantSchemas.IntentSchema("journal") }
}
public extension AssistantSchemas.JournalIntent {
    var createEntry: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateJournalEntryIntent") }
    var createAudioEntry: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateJournalAudioEntryIntent") }
    var search: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SearchJournalEntriesIntent") }
    var updateEntry: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateJournalEntryIntent") }
    var deleteEntry: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteJournalEntryIntent") }
}

// MARK: Journal · Entity
public extension AssistantSchemas {
    protocol JournalEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.JournalEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var journal: some AssistantSchemas.JournalEntity { AssistantSchemas.EntitySchema("journal") }
}
public extension AssistantSchemas.JournalEntity {
    var entry: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("JournalEntity") }
}

// MARK: Mail · Intent
public extension AssistantSchemas {
    protocol MailIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.MailIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var mail: some AssistantSchemas.MailIntent { AssistantSchemas.IntentSchema("mail") }
}
public extension AssistantSchemas.MailIntent {
    var createDraft: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateDraftIntent") }
    var updateDraft: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateDraftIntent") }
    var saveDraft: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SaveDraftIntent") }
    var deleteDraft: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteDraftIntent") }
    var sendDraft: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SendDraftIntent") }
    var forwardMail: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ForwardMailIntent") }
    var replyMail: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReplyMailIntent") }
    var archiveMail: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ArchiveMailIntent") }
    var deleteMail: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteMailIntent") }
    var updateMail: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateMailIntent") }
}

// MARK: Mail · Entity
public extension AssistantSchemas {
    protocol MailEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.MailEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var mail: some AssistantSchemas.MailEntity { AssistantSchemas.EntitySchema("mail") }
}
public extension AssistantSchemas.MailEntity {
    var account: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("MailAccountEntity") }
    var mailbox: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("MailboxEntity") }
    var draft: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("MailDraftEntity") }
    var message: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("MailMessageEntity") }
}

// MARK: Photos · Intent
public extension AssistantSchemas {
    protocol PhotosIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.PhotosIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var photos: some AssistantSchemas.PhotosIntent { AssistantSchemas.IntentSchema("photos") }
}
public extension AssistantSchemas.PhotosIntent {
    var createAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateMediaAlbumIntent") }
    var openAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenMediaAlbumIntent") }
    var updateAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateMediaAlbumIntent") }
    var deleteAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteMediaAlbumIntent") }
    var createAssets: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateMediaAssetsIntent") }
    var openAsset: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenMediaAssetIntent") }
    var updateAsset: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateMediaAssetIntent") }
    var deleteAssets: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteMediaAssetsIntent") }
    var duplicateAssets: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DuplicateMediaAssetsIntent") }
    var postToSharedAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("PostToSharedAlbumIntent") }
    var addAssetsToAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddMediaAssetsToAlbumIntent") }
    var removeAssetsFromAlbum: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("RemoveMediaAssetsFromAlbumIntent") }
    var search: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SearchMediaIntent") }
    var updateRecognizedPerson: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateMediaPersonIntent") }
    var copyEdits: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CopyMediaEditsIntent") }
    var pasteEdits: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("PasteMediaEditsIntent") }
    var cleanupPhoto: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CleanupMediaIntent") }
    var setExposure: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetMediaExposureIntent") }
    var setSaturation: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetMediaSaturationIntent") }
    var setWarmth: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetMediaWarmthIntent") }
    var toggleSuggestedEdits: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("EnhanceMediaIntent") }
    var setFilter: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ApplyMediaFilterIntent") }
    var setDepth: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetMediaApertureIntent") }
    var toggleDepth: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SetMediaDepthIntent") }
    var crop: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CropMediaIntent") }
    var straighten: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("StraightenMediaIntent") }
    var setRotation: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("RotateMediaIntent") }
}

// MARK: Photos · Entity
public extension AssistantSchemas {
    protocol PhotosEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.PhotosEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var photos: some AssistantSchemas.PhotosEntity { AssistantSchemas.EntitySchema("photos") }
}
public extension AssistantSchemas.PhotosEntity {
    var asset: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PhotoEntity") }
    var album: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PhotoAlbumEntity") }
    var recognizedPerson: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PhotoPersonEntity") }
}

// MARK: Photos · Enum
public extension AssistantSchemas {
    protocol PhotosEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.PhotosEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var photos: some AssistantSchemas.PhotosEnum { AssistantSchemas.EnumSchema("photos") }
}
public extension AssistantSchemas.PhotosEnum {
    var assetType: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("PhotoAssetType") }
    var albumType: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("PhotoAlbumType") }
    var filterType: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("PhotoFilterEffectType") }
    var rotationDirection: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("PhotoRotationDirection") }
}

// MARK: Presentation · Intent
public extension AssistantSchemas {
    protocol PresentationIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.PresentationIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var presentation: some AssistantSchemas.PresentationIntent { AssistantSchemas.IntentSchema("com.apple.Presentation") }
}
public extension AssistantSchemas.PresentationIntent {
    var create: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreatePresentationIntent") }
    var open: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenPresentationIntent") }
    var startPlayback: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("StartPlaybackPresentationIntent") }
    var stopPlayback: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("StopPlaybackPresentationIntent") }
    var update: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdatePresentationIntent") }
    var createSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreatePresentationSlideIntent") }
    var openSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenPresentationSlideIntent") }
    var setSlideTitle: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdatePresentationSlideIntent") }
    var addTextBoxToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddTextBoxToPresentationSlideIntent") }
    var addVideoToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddVideoToPresentationSlideIntent") }
    var addImageToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddImageToPresentationSlideIntent") }
    var addAudioToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddAudioToPresentationSlideIntent") }
    var addWebVideoToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddWebVideoToPresentationSlideIntent") }
    var addCommentToSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddCommentToPresentationSlideIntent") }
    var deleteSlide: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeletePresentationSlideIntent") }
}

// MARK: Presentation · Entity
public extension AssistantSchemas {
    protocol PresentationEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.PresentationEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var presentation: some AssistantSchemas.PresentationEntity { AssistantSchemas.EntitySchema("presentation") }
}
public extension AssistantSchemas.PresentationEntity {
    var slide: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PresentationSlideEntity") }
    var document: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PresentationEntity") }
    var template: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("PresentationTemplateEntity") }
}

// MARK: Reader · Intent
public extension AssistantSchemas {
    protocol ReaderIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.ReaderIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var reader: some AssistantSchemas.ReaderIntent { AssistantSchemas.IntentSchema("reader") }
}
public extension AssistantSchemas.ReaderIntent {
    var rotateDocuments: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderRotateDocumentsIntent") }
    var resizeDocuments: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderResizeDocumentsIntent") }
    var openPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderOpenPageIntent") }
    var enhanceDocuments: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderEnhanceDocumentsIntent") }
    var searchDocuments: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("SearchReaderDocumentsIntent") }
    var openDocument: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderOpenDocumentsIntent") }
    var rotatePages: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderRotatePagesIntent") }
    var deletePages: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderDeletePagesIntent") }
    var insertPages: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ReaderInsertPagesIntent") }
}

// MARK: Reader · Entity
public extension AssistantSchemas {
    protocol ReaderEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.ReaderEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var reader: some AssistantSchemas.ReaderEntity { AssistantSchemas.EntitySchema("reader") }
}
public extension AssistantSchemas.ReaderEntity {
    var document: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("ReaderDocumentEntity") }
    var page: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("ReaderPageEntity") }
}

// MARK: Reader · Enum
public extension AssistantSchemas {
    protocol ReaderEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.ReaderEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var reader: some AssistantSchemas.ReaderEnum { AssistantSchemas.EnumSchema("reader") }
}
public extension AssistantSchemas.ReaderEnum {
    var documentKind: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("ReaderDocumentKind") }
}

// MARK: Spreadsheet · Intent
public extension AssistantSchemas {
    protocol SpreadsheetIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.SpreadsheetIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var spreadsheet: some AssistantSchemas.SpreadsheetIntent { AssistantSchemas.IntentSchema("spreadsheet") }
}
public extension AssistantSchemas.SpreadsheetIntent {
    var create: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateSpreadsheetIntent") }
    var open: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenSpreadsheetIntent") }
    var update: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateSpreadsheetIntent") }
    var delete: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteSpreadsheetIntent") }
    var createSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateSheetIntent") }
    var openSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenSheetIntent") }
    var updateSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateSheetIntent") }
    var addImageToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddImageToSheetIntent") }
    var addTextBoxToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddTextboxToSheetIntent") }
    var addVideoToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddVideoToSheetIntent") }
    var addAudioToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddAudioToSheetIntent") }
    var addWebVideoToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddWebVideoToSheetIntent") }
    var addCommentToSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddCommentToSheetIntent") }
    var deleteSheet: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteSheetIntent") }
}

// MARK: Spreadsheet · Entity
public extension AssistantSchemas {
    protocol SpreadsheetEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.SpreadsheetEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var spreadsheet: some AssistantSchemas.SpreadsheetEntity { AssistantSchemas.EntitySchema("spreadsheet") }
}
public extension AssistantSchemas.SpreadsheetEntity {
    var sheet: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("SheetEntity") }
    var document: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("SpreadsheetEntity") }
    var template: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("SpreadsheetTemplateEntity") }
}

// MARK: System · Intent
public extension AssistantSchemas {
    protocol SystemIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.SystemIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var system: some AssistantSchemas.SystemIntent { AssistantSchemas.IntentSchema("system") }
}
public extension AssistantSchemas.SystemIntent {
    var search: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ShowInAppSearchResultsIntent") }
}

// MARK: VisualIntelligence · Intent
public extension AssistantSchemas {
    protocol VisualIntelligenceIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.VisualIntelligenceIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var visualIntelligence: some AssistantSchemas.VisualIntelligenceIntent { AssistantSchemas.IntentSchema("visualIntelligence") }
}
public extension AssistantSchemas.VisualIntelligenceIntent {
    var semanticContentSearch: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("ShowVisualSearchResultsInAppIntent") }
}

// MARK: Whiteboard · Intent
public extension AssistantSchemas {
    protocol WhiteboardIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.WhiteboardIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var whiteboard: some AssistantSchemas.WhiteboardIntent { AssistantSchemas.IntentSchema("whiteboard") }
}
public extension AssistantSchemas.WhiteboardIntent {
    var createBoard: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateCanvasBoardIntent") }
    var openBoard: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenCanvasBoardIntent") }
    var updateBoard: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateCanvasBoardIntent") }
    var deleteBoard: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteCanvasBoardIntent") }
    var createItem: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateCanvasItemIntent") }
    var updateItem: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("UpdateCanvasItemIntent") }
    var deleteItem: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("DeleteCanvasItemIntent") }
}

// MARK: Whiteboard · Entity
public extension AssistantSchemas {
    protocol WhiteboardEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.WhiteboardEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var whiteboard: some AssistantSchemas.WhiteboardEntity { AssistantSchemas.EntitySchema("whiteboard") }
}
public extension AssistantSchemas.WhiteboardEntity {
    var board: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("CanvasEntity") }
    var item: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("CanvasItemEntity") }
}

// MARK: Whiteboard · Enum
public extension AssistantSchemas {
    protocol WhiteboardEnum: Enum {}
}
extension AssistantSchemas.EnumSchema: AssistantSchemas.WhiteboardEnum {}
public extension AssistantSchemas.Enum where Self == AssistantSchemas.EnumSchema {
    static var whiteboard: some AssistantSchemas.WhiteboardEnum { AssistantSchemas.EnumSchema("whiteboard") }
}
public extension AssistantSchemas.WhiteboardEnum {
    var color: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("CanvasColor") }
    var itemType: some AssistantSchemas.Enum { AssistantSchemas.EnumSchema("CanvasItemType") }
}

// MARK: WordProcessor · Intent
public extension AssistantSchemas {
    protocol WordProcessorIntent: Intent {}
}
extension AssistantSchemas.IntentSchema: AssistantSchemas.WordProcessorIntent {}
public extension AssistantSchemas.Intent where Self == AssistantSchemas.IntentSchema {
    static var wordProcessor: some AssistantSchemas.WordProcessorIntent { AssistantSchemas.IntentSchema("wordProcessor") }
}
public extension AssistantSchemas.WordProcessorIntent {
    var create: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateWordProcessorDocumentIntent") }
    var open: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenWordProcessorDocumentIntent") }
    var createPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("CreateWordProcessorPageIntent") }
    var openPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("OpenWordProcessorPageIntent") }
    var addTextBoxToPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddTextBoxToWordProcessorPageIntent") }
    var addVideoToPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddVideoToWordProcessorPageIntent") }
    var addImageToPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddImageToWordProcessorPageIntent") }
    var addAudioToPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddAudioToWordProcessorPageIntent") }
    var addWebVideoToPage: some AssistantSchemas.Intent { AssistantSchemas.IntentSchema("AddWebVideoToWordProcessorPageIntent") }
}

// MARK: WordProcessor · Entity
public extension AssistantSchemas {
    protocol WordProcessorEntity: Entity {}
}
extension AssistantSchemas.EntitySchema: AssistantSchemas.WordProcessorEntity {}
public extension AssistantSchemas.Entity where Self == AssistantSchemas.EntitySchema {
    static var wordProcessor: some AssistantSchemas.WordProcessorEntity { AssistantSchemas.EntitySchema("wordProcessor") }
}
public extension AssistantSchemas.WordProcessorEntity {
    var document: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("WordProcessorDocumentEntity") }
    var page: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("WordProcessorPageEntity") }
    var template: some AssistantSchemas.Entity { AssistantSchemas.EntitySchema("WordProcessorDocumentTemplateEntity") }
}

