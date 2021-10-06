// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import "../css/app.scss"

const _css = require("../css/app.scss");

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

import React from "react";
import ReactDOM from "react-dom";
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import UrlShortenerForm from "./shorten"

const App = () => (
  <div>
    <ToastContainer
      position="top-right"
      autoClose={5000}
      hideProgressBar={false}
      newestOnTop={false}
      closeOnClick
      rtl={false}
      pauseOnFocusLoss
      draggable
      pauseOnHover
    />
    {/* Same as */}
    <ToastContainer />
    <UrlShortenerForm name="Phoenix" />
  </div>
)

const greeting = document.getElementById("react-app");
ReactDOM.render(<App />, greeting);
