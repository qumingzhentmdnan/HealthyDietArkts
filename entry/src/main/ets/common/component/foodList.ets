import dietInfo from '../bean/dietInfo'
import sql from '../utils/sqlUtil'
import dietType from '../bean/dietType'
import util from '@ohos.util';
import isDeleted from '../../view/isDeleted'
import foodPopup from '../../view/addPopup'

@Component
export default struct foodList {

  @Builder delete(){
    Image($r('app.media.ic_public_delete_filled'))
      .width('10%')
      .backgroundColor(Color.Red)
      .borderRadius(20)
  }


  @Watch('update') @Prop time:number
  @State Eat:number=0
  @Prop dietType:dietType
  @State isShow:boolean=false
  @State dietInfoList:dietInfo[]=[]
  @State dietInfoId:number=0
  @State index:number=0

  async update(){
    this.Eat=await sql.getTotalCalorieByType(new Date(this.time),this.dietType.id)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: isDeleted({dietInfo:this.dietInfoList,dietInfoId:this.dietInfoId,index:this.index,Eat:this.Eat}),
    customStyle:true,
  })

  addFoodController: CustomDialogController = new CustomDialogController({
    builder: foodPopup({dietType:this.dietType,Eat:this.Eat}),
    customStyle:true,
  })

  async aboutToAppear(){
    this.Eat=await sql.getTotalCalorieByType(new Date(this.time),this.dietType.id)
  }
  build() {
   Column(){
     Row({space:10}){
         Column(){
           Text(this.dietType.typeName)
             .fontSize(15)
         }

         Text('推荐摄入:'+this.dietType.suggestLowest+'~'+this.dietType.suggestHighest).fontSize(10).fontWeight(FontWeight.Normal)
         Text('以摄入:'+this.Eat).fontSize(10).fontWeight(FontWeight.Normal)
         Image($r('app.media.ic_public_add_norm_filled'))
           .width('5%')
           .onClick(()=>{
             this.addFoodController.open()
           })
     }.onClick(async ()=>{
       this.isShow=!this.isShow
       this.dietInfoList=await sql.getDietInfoByTypeAndDate(this.dietType.id,new Date(this.time))
       console.log(this.dietInfoList.length.toString())
     })
     .width('100%')
     .padding({left:5,right:5,top:5,bottom:5})
     .justifyContent(FlexAlign.SpaceAround)

    // List(){
    //   ForEach(this.dietInfoList,(dietInfo:dietInfo)=>{
    //     ListItem(){
    //       Row({space:45}){
    //         Text(dietInfo.food_name).fontSize(13).fontWeight(FontWeight.Bold)
    //         Text(dietInfo.count+' * '+dietInfo.weight).fontSize(13).fontWeight(FontWeight.Bold)
    //         Text('总能量:'+dietInfo.total_calorie+'kj').fontSize(13).fontWeight(FontWeight.Bold)
    //       }
    //       .backgroundColor(Color.White)
    //       .borderRadius(20)
    //       .padding({left:20,right:20,top:10,bottom:10})
    //       .width('100%')
    //       .justifyContent(FlexAlign.Center)
    //       .visibility(this.isShow?Visibility.Visible:Visibility.None)
    //     }.swipeAction({end:this.delete.bind(this)})
    //   },()=>util.generateRandomUUID(true).toString())
    // }
    // .width('100%')
    //  .layoutWeight(1)


       ForEach(this.dietInfoList,(dietInfo:dietInfo,index:number)=>{
           Row({space:45}){
             Text(dietInfo.foodName).fontSize(13).fontWeight(FontWeight.Bold)
             Text(dietInfo.count+' * '+dietInfo.weight).fontSize(13).fontWeight(FontWeight.Bold)
             Text('总能量:'+dietInfo.totalCalorie+'kj').fontSize(13).fontWeight(FontWeight.Bold)
             Image($r('app.media.ic_public_delete_filled'))
               .width('10%')
               .onClick((event=>{
                 this.dietInfoId=dietInfo.id
                 this.index=index
                 this.dialogController.open()
               }))
           }
           .backgroundColor(Color.White)
           .borderRadius(20)
           .padding({left:20,right:20,top:10,bottom:10})
           .width('100%')
           .justifyContent(FlexAlign.Center)
           .visibility(this.isShow?Visibility.Visible:Visibility.None)
       },(item:dietInfo,index)=>{
         return util.generateRandomUUID(true).toString()
       })
   }
   .width('100%')
   .backgroundColor('#FFFCFBFB')
   .borderRadius(10)
  }
}