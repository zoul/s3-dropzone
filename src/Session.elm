port module Session exposing (..)

import Json.Decode exposing (Decoder, field, map6, string)
import Json.Encode as E


type alias Session =
    { accessKey : String
    , secretKey : String
    , bucket : String
    , region : String
    , publicUrlPrefix : String
    , folderPrefix : String
    }


port saveSession : E.Value -> Cmd msg


init : Session
init =
    { accessKey = ""
    , secretKey = ""
    , bucket = ""
    , region = ""
    , publicUrlPrefix = ""
    , folderPrefix = ""
    }



-- Persistence


deleteSession : Cmd msg
deleteSession =
    saveSession E.null


encodeSession : Session -> E.Value
encodeSession session =
    E.object
        [ ( "accessKey", E.string session.accessKey )
        , ( "secretKey", E.string session.secretKey )
        , ( "bucket", E.string session.bucket )
        , ( "region", E.string session.region )
        , ( "publicUrlPrefix", E.string session.publicUrlPrefix )
        , ( "folderPrefix", E.string session.folderPrefix )
        ]


decodeSession : Decoder Session
decodeSession =
    map6 Session
        (field "accessKey" string)
        (field "secretKey" string)
        (field "bucket" string)
        (field "region" string)
        (field "publicUrlPrefix" string)
        (field "folderPrefix" string)



-- Helpers


targetUrlForFile : String -> Session -> String
targetUrlForFile fileName session =
    let
        awsHost =
            "https://" ++ session.bucket ++ ".s3." ++ session.region ++ ".amazonaws.com"

        path =
            case session.folderPrefix of
                "" ->
                    "/" ++ fileName

                "/" ->
                    "/" ++ fileName

                default ->
                    "/" ++ normalize session.folderPrefix ++ "/" ++ fileName

        host =
            case session.publicUrlPrefix of
                "" ->
                    awsHost

                customHost ->
                    stripTrailingSlash customHost
    in
    host ++ path


normalize : String -> String
normalize =
    stripLeadingSlash >> stripTrailingSlash


stripTrailingSlash : String -> String
stripTrailingSlash str =
    if String.endsWith "/" str then
        String.dropRight 1 str

    else
        str


stripLeadingSlash : String -> String
stripLeadingSlash str =
    if String.startsWith "/" str then
        String.dropLeft 1 str

    else
        str
