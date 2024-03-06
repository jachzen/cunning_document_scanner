package biz.cunning.cunning_document_scanner.fallback.models

/**
 * This class contains the original document photo, and a cropper. The user can drag the corners
 * to make adjustments to the detected corners.
 *
 * @param originalPhotoFilePath the photo file path before cropping
 * @param originalPhotoWidth the original photo width
 * @param originalPhotoHeight the original photo height
 * @param corners the document's 4 corner points
 * @constructor creates a document
 */
class Document(
    val originalPhotoFilePath: String,
    private val originalPhotoWidth: Int,
    val originalPhotoHeight: Int,
    var corners: Quad
) {
}