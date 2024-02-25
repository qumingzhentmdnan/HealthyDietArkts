@Component
export struct loginOrRegister{
  private title:string
  build(){
    Text(this.title)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.End)
      .fontColor(Color.Blue)
      .width('100%')
  }
}


@Component
export struct description{
  private title:string
  build(){
    Text(this.title)
    .fontSize(20)
    .fontWeight(FontWeight.Bolder)
    .fontWeight(FontWeight.Bold)
    .textAlign(TextAlign.Start)
    .width('90%')
  }
}