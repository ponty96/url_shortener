import React, { useState } from "react"
import { toast } from 'react-toastify';
import { ENDPOINTS } from "./constants"
import { v4 } from 'uuid';

const UI_STATES = {
  FORM_STATE: "FORM_STATE",
  SUCCESS_STATE: "SUCCESS_STATE"
}
const UrlShortenerForm: React.FC = () => {
  const [uiState, setUIState] = useState(UI_STATES.FORM_STATE)
  const [longUrl, setLongUrl] = useState("")
  const [shortUrl, setShortUrl] = useState("")

  const resetUIState = () => {
    setLongUrl("")
    setUIState(UI_STATES.FORM_STATE)
  }

  const shortenURL = async () => {
    // set the value of the short url here
    const response = await makeAPI()

    // success
    if (response && response["data"]) {
      setShortUrl(response["data"]["url"])
      setUIState(UI_STATES.SUCCESS_STATE)
    } else {
      toast.error(`Could not shortened text ${response["message"]}`)
    }
  }

  const copyToClipboard = () => {
    navigator.clipboard.writeText(shortUrl).then(function () {
      toast.info('Copied to clipboard', { autoClose: 1000, hideProgressBar: true, closeButton: false })
    }, function (err) {
      console.error('Async: Could not copy text: ', err);
      toast.error('Could not copy text')
    });
  }

  const setOrGetUUI = () => {
    const exisitngUUID = localStorage.getItem("userUUID") || v4()

    localStorage.setItem("userUUID", exisitngUUID)

    return exisitngUUID
  }

  const makeAPI = () => {
    const payload = {
      user_id: setOrGetUUI(),
      long_url: longUrl
    }
    return fetch(ENDPOINTS.SHORT_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    }).then((response) => response.json())
      .catch((error) => {
        return error
      })
  }

  if (uiState == UI_STATES.FORM_STATE) {
    return (
      <div className="container" id="inputBox">
        <div className="row justify-content-center">
          <div className="col-11 col-md-6 form-box p-3">
            <p className="text-center mb-2">Enter a long URL to make a LittleURL</p>
            <section>
              <div>
                <input type="url" name="url" id="url" required value={longUrl} onChange={e => setLongUrl(e.target.value)} />
              </div>
              <input type="submit" value="Make LittleURL!" className="mt-3" id="submit" onClick={shortenURL} />
            </section>
          </div>
        </div>
      </div>
    )
  } else {
    return (
      <div className="container">
        <div className="row justify-content-center">
          <div className="col-11 col-md-6 form-box p-3">
            <p className="mb-2">Your Long URL</p>
            <div>
              <input type="url" name="longUrl" id="longUrl" readOnly={true} value={longUrl} />
            </div>
            <p className="mt-3 mb-1">LittleURL</p>
            <div>
              <input type="text" name="shortUrl" id="shortUrl" readOnly={true} value={shortUrl} />
            </div>
            <div className="d-flex justify-content-between">
              <button type="button" className="btn btn-primary" onClick={resetUIState}>Shorten another</button>
              <div>
                <a className="btn btn-info visit" href={shortUrl} target="_blank">Visit URL</a>
                <button type="button" className="btn btn-success" onClick={copyToClipboard}>Copy</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default UrlShortenerForm
