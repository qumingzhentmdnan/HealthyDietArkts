import PreferenceUtil from '../common/utils/PreferenceUtil'
import UserInfo from './UserInfo'
import chatPage from './chatPage'
import homePage from './homePage'

@Entry
@Component
struct Index {

  @State index: number = 0;
  async aboutToAppear(){
      let res=await PreferenceUtil.getPreferenceValue('token')
  }

  @Builder TabBuilder(name: string,picture:ResourceStr,index:number) {
    Column() {
      Image(picture)
        .width(40)
        .fillColor(index===this.index?Color.Blue:Color.Gray)
      Text(name)
        .fontColor(index===this.index?Color.Blue:Color.Gray)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .lineHeight(22)
    }.width('100%') .height('100%')
  }


  build() {
      Tabs({barPosition:BarPosition.End}) {
        TabContent() {
          homePage()
        }
        .tabBar(this.TabBuilder('首页',$r('app.media.ic_calendar'),0))

        TabContent() {
          chatPage()
        }
        .tabBar(this.TabBuilder('问一问',$r('app.media.ic_public_email'),1))

        TabContent() {
          UserInfo()
        }
        .tabBar(this.TabBuilder('我的',$r('app.media.ic_user_portrait'),2))
      }.onChange(value=>{
        this.index=value
      })

    .height('100%')
      .width('100%')
      .barHeight(80)
    .backgroundColor($r('app.color.start_window_background'))
  }
}