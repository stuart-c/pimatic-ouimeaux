# #Shell device configuration options
module.exports = {
  title: "pimatic-ouimeaux device config schemas"
  OuimeauxSwitch: {
    title: "OuimeauxSwitch config options"
    type: "object"
    extensions: ["xConfirm", "xLink", "xOnLabel", "xOffLabel"]
    properties:
      serialnumber:
        description: ""
        type: "string"
        options:
          hidden: yes
      host:
        description: ""
        type: "string"
        options:
          hidden: yes
      model:
        description: ""
        type: "string"
        options:
          hidden: yes
      lastState:
        description: ""
        type: "boolean"
        default: false
        options:
          hidden: yes
  }
}
