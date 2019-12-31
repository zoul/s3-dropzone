module SignIn exposing (Model, Msg, init, update, viewForm)

import Html exposing (Html)
import Material.Button exposing (buttonConfig, textButton)
import Material.Dialog exposing (dialog, dialogConfig)
import Material.TextField exposing (textField, textFieldConfig)
import Session exposing (Session, encodeSession, saveSession)


type alias Form =
    { accessKey : String
    , secretKey : String
    , bucket : String
    }


type Model
    = FillingForm Form
    | SignedIn Session


type Msg
    = UpdateAccessKey String
    | UpdateSecretKey String
    | UpdateBucket String
    | SubmitForm


init : Model
init =
    FillingForm { accessKey = "", secretKey = "", bucket = "" }


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Session )
update msg model =
    case ( model, msg ) of
        ( FillingForm form, UpdateAccessKey s ) ->
            ( FillingForm { form | accessKey = s }, Cmd.none, Nothing )

        ( FillingForm form, UpdateSecretKey s ) ->
            ( FillingForm { form | secretKey = s }, Cmd.none, Nothing )

        ( FillingForm form, UpdateBucket s ) ->
            ( FillingForm { form | bucket = s }, Cmd.none, Nothing )

        ( FillingForm form, SubmitForm ) ->
            let
                session =
                    makeSession form

                saveCmd =
                    session |> encodeSession |> saveSession
            in
            ( SignedIn session, saveCmd, Just session )

        _ ->
            ( model, Cmd.none, Nothing )


makeSession : Form -> Session
makeSession form =
    { accessKey = form.accessKey
    , secretKey = form.secretKey
    , bucket = form.bucket
    , region = "eu-central-1"
    , publicUrlPrefix = ""
    , folderPrefix = ""
    }



-- VIEW


viewForm : Html Msg
viewForm =
    dialog
        { dialogConfig
            | open = True
            , onClose = Nothing
        }
        { title = Nothing
        , content =
            [ textField
                { textFieldConfig
                    | placeholder = Just "Bucket Name"
                    , onInput = Just UpdateBucket
                    , fullwidth = True
                    , required = True
                }
            , textField
                { textFieldConfig
                    | onInput = Just UpdateAccessKey
                    , fullwidth = True
                    , placeholder = Just "Access Key"
                    , required = True
                }
            , textField
                { textFieldConfig
                    | placeholder = Just "Secret Key"
                    , onInput = Just UpdateSecretKey
                    , fullwidth = True
                    , required = True
                    , type_ = "password"
                }
            ]
        , actions =
            [ textButton
                { buttonConfig
                    | onClick = Just SubmitForm
                }
                "Sign In"
            ]
        }
