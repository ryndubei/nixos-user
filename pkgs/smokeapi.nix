{ fetchzip, ... }:

fetchzip {
  url =
    "https://github.com/acidicoala/SmokeAPI/releases/download/v2.0.5/SmokeAPI-v2.0.5.zip";
  hash = "sha256-urOLmQ2xY4NKxyCznVUOMNAMSY7btLhKbca/FMHNHNQ=";
  stripRoot = false;
}
