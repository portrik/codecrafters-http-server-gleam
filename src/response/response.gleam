pub type HTTPStatus {
  Continue
  SwitchingProtocols
  Processing
  EarlyHints

  OK
  Created
  Accepted
  NonAuthoritativeInformation
  NoContent
  ResetContent
  PartialContent
  MultiStatus

  MultipleChoices
  MovedPermanently
  Found
  SeeOther
  NotModified
  UseProxy
  TemporaryRedirect
  PermanentRedirect

  BadRequest
  Unauthorized
  PaymentRequired
  Forbidden
  NotFound
  MethodNotAllowed
  NotAcceptable
  ProxyAuthenticationRequired
  RequestTimeout
  Conflict
  Gone
  LengthRequired
  PreconditionFailed
  PayloadTooLarge
  URITooLong
  UnsupportedMediaType
  RangeNotSatisfiable
  ExpectationFailed
  ImATeapot
  EnhanceYourCalm
  MisdirectedRequest
  UnprocessableEntity
  Locked
  FailedDependency
  TooEarly
  UpgradeRequired
  PreconditionRequired
  TooManyRequests
  RequestHeaderFieldsTooLarge
  UnavailableForLegalReasons

  InternalServerError
  NotImplemented
  BadGateway
  ServiceUnavailable
  GatewayTimeout
  HTTPVersionNotSupported
  VariantAlsoNegotiates
  InsufficientStorage
  LoopDetected
  NotExtended
  NetworkAuthenticationRequired
}

pub fn get_status_code(status: HTTPStatus) -> Int {
  case status {
    Continue -> 100
    SwitchingProtocols -> 101
    Processing -> 102
    EarlyHints -> 103

    OK -> 200
    Created -> 201
    Accepted -> 202
    NonAuthoritativeInformation -> 203
    NoContent -> 204
    ResetContent -> 205
    PartialContent -> 206
    MultiStatus -> 207

    MultipleChoices -> 300
    MovedPermanently -> 301
    Found -> 302
    SeeOther -> 303
    NotModified -> 304
    UseProxy -> 305
    TemporaryRedirect -> 307
    PermanentRedirect -> 308

    BadRequest -> 400
    Unauthorized -> 401
    PaymentRequired -> 402
    Forbidden -> 403
    NotFound -> 404
    MethodNotAllowed -> 405
    NotAcceptable -> 406
    ProxyAuthenticationRequired -> 407
    RequestTimeout -> 408
    Conflict -> 409
    Gone -> 410
    LengthRequired -> 411
    PreconditionFailed -> 412
    PayloadTooLarge -> 413
    URITooLong -> 414
    UnsupportedMediaType -> 415
    RangeNotSatisfiable -> 416
    ExpectationFailed -> 417
    ImATeapot -> 418
    EnhanceYourCalm -> 420
    MisdirectedRequest -> 421
    UnprocessableEntity -> 422
    Locked -> 423
    FailedDependency -> 424
    TooEarly -> 425
    UpgradeRequired -> 426
    PreconditionRequired -> 428
    TooManyRequests -> 429
    RequestHeaderFieldsTooLarge -> 431
    UnavailableForLegalReasons -> 451

    InternalServerError -> 500
    NotImplemented -> 501
    BadGateway -> 502
    ServiceUnavailable -> 503
    GatewayTimeout -> 504
    HTTPVersionNotSupported -> 505
    VariantAlsoNegotiates -> 506
    InsufficientStorage -> 507
    LoopDetected -> 508
    NotExtended -> 510
    NetworkAuthenticationRequired -> 511
  }
}

pub fn get_status_reason(status: HTTPStatus) -> String {
  case status {
    Continue -> "Continue"
    SwitchingProtocols -> "Switching Protocols"
    Processing -> "Processing"
    EarlyHints -> "Early Hints"

    OK -> "OK"
    Created -> "Created"
    Accepted -> "Accepted"
    NonAuthoritativeInformation -> "Non-Authoritative Information"
    NoContent -> "No Content"
    ResetContent -> "Reset Content"
    PartialContent -> "Partial Content"
    MultiStatus -> "Multi-Status"

    MultipleChoices -> "Multiple Choices"
    MovedPermanently -> "Moved Permanently"
    Found -> "Found"
    SeeOther -> "See Other"
    NotModified -> "Not Modified"
    UseProxy -> "Use Proxy"
    TemporaryRedirect -> "Temporary Redirect"
    PermanentRedirect -> "Permanent Redirect"

    BadRequest -> "Bad Request"
    Unauthorized -> "Unauthorized"
    PaymentRequired -> "Payment Required"
    Forbidden -> "Forbidden"
    NotFound -> "Not Found"
    MethodNotAllowed -> "Method Not Allowed"
    NotAcceptable -> "Not Acceptable"
    ProxyAuthenticationRequired -> "Proxy Authentication Required"
    RequestTimeout -> "Request Timeout"
    Conflict -> "Conflict"
    Gone -> "Gone"
    LengthRequired -> "Length Required"
    PreconditionFailed -> "Precondition Failed"
    PayloadTooLarge -> "Payload Too Large"
    URITooLong -> "URI Too Long"
    UnsupportedMediaType -> "Unsupported Media Type"
    RangeNotSatisfiable -> "Range Not Satisfiable"
    ExpectationFailed -> "Expectation Failed"
    ImATeapot -> "I'm a Teapot"
    EnhanceYourCalm -> "Enhance Your Calm"
    MisdirectedRequest -> "Misdirected Request"
    UnprocessableEntity -> "Unprocessable Entity"
    Locked -> "Locked"
    FailedDependency -> "Failed Dependency"
    TooEarly -> "Too Early"
    UpgradeRequired -> "Upgrade Required"
    PreconditionRequired -> "Precondition Required"
    TooManyRequests -> "Too Many Requests"
    RequestHeaderFieldsTooLarge -> "Request Header Fields Too Large"
    UnavailableForLegalReasons -> "Unavailable For Legal Reasons"

    InternalServerError -> "Internal Server Error"
    NotImplemented -> "Not Implemented"
    BadGateway -> "Bad Gateway"
    ServiceUnavailable -> "Service Unavailable"
    GatewayTimeout -> "Gateway Timeout"
    HTTPVersionNotSupported -> "HTTP Version Not Supported"
    VariantAlsoNegotiates -> "Variant Also Negotiates"
    InsufficientStorage -> "Insufficient Storage"
    LoopDetected -> "Loop Detected"
    NotExtended -> "Not Extended"
    NetworkAuthenticationRequired -> "Network Authentication Required"
  }
}
