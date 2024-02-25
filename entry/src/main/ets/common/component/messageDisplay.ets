import dialogInfo from '../bean/dialogInfo'
import audioComponent from '../component/audioComponent'

@Component
export default struct messageDisplay {
  @ObjectLink item:dialogInfo

  imageUrl:string
  build() {
    Column({space:20}){
      Row({space:10}){
        Text(this.item.userRequest)
          .borderRadius(10)
          .borderWidth(1)
          .alignSelf(ItemAlign.End)
          .margin({left:'30%'})
          .padding({left:2,right:2,bottom:2,top:2})
          .backgroundColor('#8de2c3')
          .visibility(this.item.userRequest?Visibility.Visible:Visibility.None)

        Image(this.imageUrl?this.imageUrl:$r('app.media.default_head_picture'))
          .borderRadius(20)
          .width('10%')
          .borderWidth(1)
          .visibility(this.item.userRequest?Visibility.Visible:Visibility.None)
      }
      .width('95%')
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)


      Column() {
        Row({ space: 10 }) {
          Image(this.item.user_id == 0 ? $r('app.media.ningguang') : this.item.user_id == 1 ? $r('app.media.naweilaite') : this.item.user_id == 2 ? $r('app.media.bachongshenzi') : $r('app.media.funingna'))
            .borderRadius(20)
            .width('10%')
            .borderWidth(1)

          Text(this.item.text)
            .borderRadius(10)
            .borderWidth(1)
            .margin({ right: '30%' })
            .padding({ left: 2, right: 2, bottom: 2, top: 2 })
            .backgroundColor('#ffcc83')
        }
        .width('90%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        audioComponent({text: this.item.text, user_id: this.item.user_id,file_path:this.item.file_path,userRequest:this.item.userRequest})
      }.visibility(this.item.text?Visibility.Visible:Visibility.None)

    }
  }
}