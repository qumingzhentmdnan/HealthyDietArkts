import dateUtil from '../common/utils/DateUtil'
import foodList from  '../common/component/foodList'
import axios from '@ohos/axios'
import PreferenceUtil from '../common/utils/PreferenceUtil'
import dietType from '../common/bean/dietType'
import sql from '../common/utils/sqlUtil'
import util from '@ohos.util';
import foodInfo from '../common/bean/foodInfo'
import router from '@ohos.router'

@Entry
@Component
export  default struct HomePage {
  url:string='http://192.168.73.99:8080'
  @State message: string = 'Hello World'
  @State date:number=0
  @Provide total:number=2222
  @Provide alreadyEat:number=587
  @Provide remaintEat:number=587
  @State DietTypeList:dietType[]=[]
  @State FoodInfoList:foodInfo[]=[]


  @Builder delete(index){
    Image($r('app.media.ic_public_delete_filled'))
      .width('10%')
      .backgroundColor(Color.Red)
      .borderRadius(20)
      .onClick(()=>{
        this.DietTypeList.splice(index,1)
        sql.deletedDietType(this.DietTypeList[index].id)
      })
  }

  async aboutToAppear(){
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    this.date=dateUtil.beginTimeOfDay(new Date())
    //获取饮食类型数据
    let haveDietType=await PreferenceUtil.getPreferenceValue('dietType',false)
    console.log(haveDietType.toString())
    if(!haveDietType){
      try {
        let res=await axios.get(this.url+'/dietType/getDietType',{
          headers:{
            token:token
          }
        })
        if(res.data.code==20000){
          console.log('通过axios查询饮食类型并成功返回')
          this.DietTypeList=res.data.data.list
          console.log(this.DietTypeList.length.toString())
          sql.setDietType(this.DietTypeList)
          PreferenceUtil.putPreferenceValue('dietType',true)
        }
      }catch (Exception){
        console.log(Exception);
      }
    }else{
      this.DietTypeList=await sql.getAllDietType()
    }

    //获取详细饮食信息数据
    let haveDietInfo=await PreferenceUtil.getPreferenceValue('dietInfo',false)
    console.log(haveDietType.toString())
    if(!haveDietInfo){
      try {
        let res=await axios.get(this.url+`/dietInfo/getDietInfo`,{
          headers:{
            token:token
          }
        })
        if(res.data.code==20000){
          console.log('通过axios查询饮食详细并成功返回')
          await sql.setDietInfoList(res.data.data.list)
          PreferenceUtil.putPreferenceValue('dietInfo',true)
        }
      }catch (Exception){
        console.log(Exception);
      }
    }

    this.alreadyEat=await sql.getTotalCalorie(new Date(this.date))
    this.remaintEat=this.total-this.alreadyEat>0?this.total-this.alreadyEat:0

    //获取详细饮食信息数据
    let haveFoodInfo=await PreferenceUtil.getPreferenceValue('foodInfo',false)
    console.log(haveFoodInfo.toString())
    if(!haveFoodInfo){
      try {
        let res=await axios.get(this.url+`/foodInfo/getAll`,{
          headers:{
            token:token
          }
        })
        if(res.data.code==20000){
          console.log('通过axios查询食物详细并成功返回')
          await sql.setFoodInfo(res.data.data.list)
          PreferenceUtil.putPreferenceValue('foodInfo',true)
        }
      }catch (Exception){
        console.log(Exception);
      }
    }
  }


  build() {
    Column({space:20}){
      Search({placeholder:'查看常见食物'})
        .width('90%')
        .searchButton('搜索')
        .margin({top:20})
        .onSubmit((value)=>{
          console.log(value)
          router.pushUrl({url:'pages/SearchResultPage',params:{
            key:value
          }})
        })

      Row({space:10}){
        Text(dateUtil.formatDate(this.date))
        Image($r('app.media.ic_public_arrow_down_0'))
          .width('6%')
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date("2000-1-1"),
              end: new Date(),
              selected:new Date(this.date),
              lunar:false,
              onAccept: async  (value: DatePickerResult) => {
                this.date= dateUtil.beginTimeOfDay(new Date(value.year, value.month, value.day))
                this.alreadyEat=await sql.getTotalCalorie(new Date(this.date))
                this.remaintEat=this.total-this.alreadyEat>0?this.total-this.alreadyEat:0
              },
              onCancel: () => {
                console.info("DatePickerDialog:onCancel()")
              },
              onChange: (value: DatePickerResult) => {
                this.date= dateUtil.beginTimeOfDay(new Date(value.year, value.month, value.day))
              }
            })
      })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({left:'15%'})

      Row({space:30}){
        Column(){
          Text('以摄入')
            .fontSize(15)
          Text(this.alreadyEat.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
        }
        Stack() {
          Column({ space: 10 }) {
            Text('建议剩余摄入')
              .fontSize(15)
            Text((this.remaintEat).toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bolder)
            Text('Cal')
              .fontSize(15)
              .fontWeight(FontWeight.Bolder)
          }

          Progress({ value: this.alreadyEat, total: this.total, type: ProgressType.Ring })
            .width('40%')
            .style({ strokeWidth: 10 })
            .backgroundColor(Color.Gray)
        }
        .alignContent(Alignment.Center)


        Column(){
          Text('建议摄入')
            .fontSize(15)
          Text(this.total.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
        }
      }
      .backgroundColor('#9beda4')
      .width('95%')
      .borderRadius(20)
      .justifyContent(FlexAlign.SpaceAround)


      List(){
          ForEach(this.DietTypeList,(element:dietType, index)=>{
            ListItem(){
              foodList({dietType:element,time:this.date})
            }
            .swipeAction({end:this.delete(index)}).margin({top:10,bottom:10})
          },()=>util.generateRandomUUID(true).toString())
      }
      .width('90%')
      .layoutWeight(1)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}