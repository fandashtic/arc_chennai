import axios from "axios";

export default axios.create({
  baseURL: "http://retail.local.fandashtic.com/api/",
  //baseURL: "http://localhost:3002/api/",
  responseType: "json"
});