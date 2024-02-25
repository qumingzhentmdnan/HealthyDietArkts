import axios from '@ohos/axios'
import dietInfo from '../common/bean/dietInfo'
import dietType from '../common/bean/dietType'
import sql from '../common/utils/sqlUtil'
import PreferenceUtil from '../common/utils/PreferenceUtil'
@CustomDialog

export default struct agreement {
  controller:CustomDialogController
  @State dietInfo:dietInfo=new dietInfo()
  @State dietTypeList:dietType[]=[]
  @State type:Array<SelectOption>=[]
  @Prop dietType:dietType
  @State calorie:number=0
  @Consume alreadyEat:number
  @Consume remaintEat:number
  @Consume total:number
  @Link Eat:number
  url:string='http://192.168.73.99:8080'

  async aboutToAppear(){
    this.dietTypeList=await sql.getAllDietType()
    for (let i = 0; i < this.dietTypeList.length; i++) {
      this.type.push({value:this.dietTypeList[i].typeName})
    }
  }

  async addFood(){
    this.dietInfo.totalCalorie=this.calorie*this.dietInfo.count
    this.dietInfo.type=this.dietType.id
    this.dietInfo.createTime=new Date().toString()
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    try {
      let res=await axios({
        url:this.url+'/dietInfo/addDietInfo',
        method:'post',
        data:{
          type:this.dietInfo.type,
          foodName:this.dietInfo.foodName,
          totalCalorie:this.dietInfo.totalCalorie,
          count:this.dietInfo.count,
          weight:this.dietInfo.weight,
        },
        headers:{
          token:token
        }
      })
      if(res.data.code==20000){
        let diet:dietInfo[]=[]
        diet.push(this.dietInfo)
        sql.setDietInfoList(diet)
        console.log('添加成功');
        this.Eat+=this.dietInfo.totalCalorie
        this.alreadyEat=this.alreadyEat+this.dietInfo.totalCalorie
        this.remaintEat=this.total-this.alreadyEat>0?this.total-this.alreadyEat:0
      }
    }catch (Exception){
      console.log(Exception)
    }
  }

  build() {
    Column(){
      Text('添加食物')
        .width(200)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin(10)
      Select(this.type)
        .selected(0)
        .value(this.dietType.typeName)
      Column({space:20}){
        Row({space:5}){
          Text('食物名称:')
          TextInput({placeholder:'请输入食物名称',text:this.dietInfo.foodName})
            .width('50%')
            .onChange(value=>{
              this.dietInfo.foodName=value
            })
        }
        Row({space:5}){
          Text('食物重量:')
          TextInput({placeholder:'请输入食物重量',text:this.dietInfo.weight.toString()})
            .width('50%')
            .onChange(value=>{
              this.dietInfo.weight=value
            })
        }
        Row({space:5}){
          Text('食物能量:')
          TextInput({placeholder:'请输入食物能量',text:this.calorie.toString()})
            .width('50%')
            .onChange(value=>{
              this.calorie=parseFloat(value)
            })
        }
        Row({space:5}){
          Text('食物份数:')
          Counter() {
            Text(this.dietInfo.count.toString())
          }
          .onInc(() => {
            this.dietInfo.count++
          })
          .onDec(() => {
            if(this.dietInfo.count<=0)
              return
            this.dietInfo.count--
          })
          .width('50%')
        }
      }
      .margin({bottom:20})

      Row({space:30}){
        Button('确认')
          .backgroundColor($r('app.color.green'))
          .onClick(async ()=>{
            await this.addFood()
            this.controller.close()
          })
        Button('取消')
          .backgroundColor($r('app.color.gray'))
          .onClick(()=>{
            this.controller.close()
          })
      }
    }
    .width('90%')
    .padding(10)
    .backgroundColor('#9beda4')
    .borderRadius(20)
  }
}