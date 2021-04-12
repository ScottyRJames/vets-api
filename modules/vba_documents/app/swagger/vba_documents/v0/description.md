The Benefits Intake API allows authorized third-party systems used by Veteran Service Organizations and agencies to digitally submit claim documents directly to the Veterans Benefits Administration's (VBA) claims intake process.

This API provides a secure and efficient alternative to paper or fax document submissions. VBA can begin processing documents submitted through this API immediately, which ultimately allows VA to provide Veterans with claim decisions more quickly.

It also saves users time by reporting documents' status until they reach Veterans Benefits Management System (VBMS), where the documents are reviewed. This eliminates the need for users to switch between systems to manually check whether documents have reached VBMS.

Visit our VA Lighthouse [support portal](https://developer.va.gov/support) for further assistance.

## Technical Summary
The Benefits Intake API accepts a payload consisting of a document in PDF format, zero or more optional attachments in PDF format, and some JSON metadata. The metadata describes the document and attachments, and identifies the person for whom it is being submitted. This payload is encoded as binary multipart/form-data (not base64). A unique identifier supplied with the payload can subsequently be used to request the processing status of the uploaded document package.

API consumers are encouraged to validate the `zipcode` and `fileNumber` fields before submission according to their description in the DocumentUploadMetadata model.

## Design
### Attachment & File Size Limits
There is not a limit on the number of documents that can be submitted at once, but file sizes can impact the number of documents accepted.

The file size limit for each document is 100 MB. The entire package, which is all documents combined into one file, is limited to 5 GB.

### Date of Receipt
The date and time documents are submitted to the Benefits Intake API is used as the official VA date of receipt. However, note that until a document status of `received`, `processing`, or `success` is returned, a client cannot consider the document received by VA.

A status of `received` means that the document package has been transmitted, but possibly not validated. Any errors with the document package (unreadable PDF, etc) may cause the status to change to `error`.

If the document status is `error`, VA has not received the submission and cannot honor the submission date as the date of receipt.

### Authorization
API requests are authorized by means of a symmetric API token, provided in an HTTP header with name `apikey`.

### Upload Operation
Allows a client to upload a document package (form + attachments + metadata).

1. Client Request: POST https://sandbox-api.va.gov/services/vba_documents/v0/
    * No request body or parameters required

2. Service Response: A JSON API object with the following attributes:
    * `guid`: An identifier used for subsequent status requests
    * `location`: A URL to which the actual document package payload can be submitted in the next step. The URL is specific to this upload request, and should not be re-used for subsequent uploads. The URL is valid for 900 seconds (15 minutes) from the time of this response. If the location is not used within 15 minutes, the GUID will expire. Once expired, status checks on the GUID will return a status of `expired`.
      * Note: If, after you've submitted a document, the status hasn't changed to `uploaded` before 15 minutes has elapsed, we recommend retrying the upload in order to make sure the document properly reaches our servers 

 3. Client Request: PUT to the location URL returned in Step 2.
    * Request body should be encoded as multipart/form-data, equivalent to that generated by an HTML form submission or using “curl -F…”. The format is described in more detail below.
    * No `apikey` authorization header is required for this request, as authorization is embedded in the signed location URL.

4. Service Response: The HTTP status indicates whether the upload was successful.
    * Additionally, the response includes an ETag header containing an MD5 hash of the submitted payload. This can be compared to the submitted payload to ensure data integrity of the upload.

### Status Simulation
Given the downstream connections of this API, we allow **(IN SANDBOX ENVIRONMENT ONLY)** passing in a header `Status-Override` on the `/uploads/{id}` endpoint that will allow you to change the status of your submission to simulate the various scenarios. The available statuses are `pending`, `uploaded`, `received`, `processing`, `success`, and `error`. The meaning of the various statuses is listed below in Models under DocumentUploadStatusAttributes.

### Status Caching
Due to current system limitations, data for the `/uploads/report` endpoint is cached for one hour.

A request to the `/uploads/{id}` endpoint will return a real-time status for that GUID, and update its status in `/uploads/report`.

The `updated_at` field indicates the last time the status for a given GUID was updated.

## Reference
Raw Open API Spec: https://api.va.gov/services/vba_documents/docs/v0/api