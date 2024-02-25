@CustomDialog
export default struct simplePopup {
  controller:CustomDialogController
  message:string
  build() {
    Column(){
      Text(this.message)
        .width('40%')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Gray)
        .fontColor(Color.White)
        .borderRadius(10)
    }
  }
}