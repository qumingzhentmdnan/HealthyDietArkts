import axios from '@ohos/axios'
import dietInfo from '../common/bean/dietInfo'
import sql from '../common/utils/sqlUtil'
import PreferenceUtil from '../common/utils/PreferenceUtil'

@CustomDialog
export default struct isDeleted {
  @Consume alreadyEat:number
  @Consume remaintEat:number
  @Consume total:number
  @Link Eat:number
  controller:CustomDialogController
  @Link dietInfo:dietInfo[]
  dietInfoId:number
  index:number
  url:string='http://192.168.73.99:8080'

  async deleted(){
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    axios.delete(this.url+`/dietInfo/deleteDietInfo/${this.dietInfoId}`,{
      headers:{
        token:token
      }
    }).then(()=>{
      let calorie=this.dietInfo[this.index].totalCalorie
      this.alreadyEat-=calorie
      this.Eat-=calorie
      this.remaintEat=this.total-this.alreadyEat>0?this.total-this.alreadyEat:0
      sql.deletedDietInfo(this.dietInfoId)
      this.dietInfo.splice(this.index,1)
    }).catch(Exception=>{
      console.log(this.url+`/dietInfo/deleteDietInfo/${this.dietInfoId}`)
      console.log(Exception)
    })
  }

  build() {
    Column(){
      Text('确定要删除吗？')
        .width(200)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin(10)
      Row({space:30}){
        Button('确认')
          .backgroundColor($r('app.color.green'))
          .onClick(async ()=>{
            await this.deleted()
            this.controller.close()
          })
        Button('取消')
          .backgroundColor($r('app.color.gray'))
          .onClick(()=>{

            this.controller.close()
          })
      }
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FF8FB2FC')
    .borderRadius(10)
    .borderWidth(1)
    .width('80%')
  }
}