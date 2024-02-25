import router from '@ohos.router'
import sql from '../common/utils/sqlUtil'
import foodInfo from '../common/bean/foodInfo'
import util from '@ohos.util'

@Entry
@Component
struct SearchResultPage {
  @State foodInfo:foodInfo[]=[]

  async onPageShow(){
    let key=router.getParams()['key']
    console.log(key)
    this.foodInfo=await sql.getFoodInfoByKey(key)
  }

  build() {
    Column(){
      Image($r('app.media.ic_public_back'))
        .width('10%')
        .alignSelf(ItemAlign.Start)
        .margin({top:15,left:15})
        .onClick(()=>{
          router.back()
        })
      Image($r('app.media.NullResult'))
        .width('80%')
        .visibility(this.foodInfo.length>0?Visibility.None:Visibility.Visible)
        .margin({top:80})
      List(){
        ForEach(this.foodInfo,(item:foodInfo,index:number)=>{
          ListItem(){
            Row(){
              Text(item.foodName)
                .fontSize(20)
              Text(item.weight)
                .fontSize(20)
              Text(item.calorie+'kj')
                .fontSize(20)
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width('95%')
            .margin({top:15})
          }
        },()=>util.generateRandomUUID(true).toString())
      }
      .layoutWeight(1)
    }
  }
}