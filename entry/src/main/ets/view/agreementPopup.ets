

@CustomDialog
export default struct agreement {
  controller:CustomDialogController
  confirm:()=> void
  cancel:()=> void
  build() {
    Column(){
      Text('用户协议')
        .width(200)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin(10)
      Text($r('app.string.user_privacy_content'))
        .width(200)
        .margin({bottom:15})
      Row({space:30}){
        Button('确认')
          .backgroundColor($r('app.color.green'))
          .onClick(()=>{
            this.controller.close()
            this.confirm();
          })
        Button('取消')
          .backgroundColor($r('app.color.gray'))
          .onClick(()=>{
            this.controller.close()
            this.cancel()
          })
      }
    }
    .width('100%')
    .padding(10)
  }
}