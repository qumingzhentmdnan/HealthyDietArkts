import sql from '../common/utils/sqlUtil'
import dialogInfo from '../common/bean/dialogInfo'
import PreferenceUtil from '../common/utils/PreferenceUtil'
import axios from '@ohos/axios'
import url from '@ohos.url'
import simplePopup from '../view/simplePopup'
import messageDisplay from '../common/component/messageDisplay'
import common from '@ohos.app.ability.common'

@Preview
@Component
export default struct ChatPage {
  @State audioList:dialogInfo[]= []
  @State imageUrl:string=''
  @State message:string=''
  @State modelId:number=0
  @State err:string=''


  url:string='http://192.168.73.99:8080'

  async aboutToAppear(){
      let res=await PreferenceUtil.getPreferenceValue('headPicture','')
      this.audioList=await sql.queryAudio()
      console.log('查询')
      for (let index = 0; index < this.audioList.length; index++) {
        let item:dialogInfo=this.audioList[index]
        console.log(item.file_path)
      }
      this.imageUrl=res.toString()
  }


  async getMessage(){
    let token =await PreferenceUtil.getPreferenceValue('token','') as string
    try {
      let res=await axios.get(this.url+'/chat/getChat',{
        params:{
          id:this.modelId,
          message:this.message
        },
        headers:{
          token:token
        }
      })
      if(res.data.code==20000){
        console.log(res.data.data.message);
        this.audioList[this.audioList.length-1].text=res.data.data.message
      }else{
        this.err=res.data.message
        this.Popup()
      }
    }catch (Exception){
      console.log(Exception)
    }
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: simplePopup({message:this.err}),
    customStyle:true,
  })

  Popup:Function=()=>{
    //防止点击跳转按钮导致失去焦点弹出信息
    this.dialogController.open()
    //弹出窗口会导致失去焦点，修改为true，防止再弹出一次
    setTimeout(()=>{
      this.dialogController.close()
    },500)
  }

  build() {
    Column(){
      Text('饮食助手')
        .fontSize(25)
        .fontWeight(FontWeight.Medium)
        .margin({top:'5%',bottom:'5%'})
      Select([{value:'凝光'},{value:'那维莱特'},{value:'八重神子'},{value:'芙宁娜'}])
        .selected(0)
        .value('凝光')
        .alignSelf(ItemAlign.Start)
        .margin({left:10})
        .onSelect((index)=>{
          this.modelId=index
        })

      List({space:10}){
        ForEach(this.audioList,(element:dialogInfo)=>{
          ListItem(){
            messageDisplay({item:element as dialogInfo,imageUrl:this.imageUrl})
          }
        })
      }.layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)

      Row({space:20}){
        TextInput({placeholder:'点此输入消息',text:this.message})
          .width('70%')
          .onChange(value=>{
            this.message=value
          })
          .type(InputType.Normal)
        Button('发送')
          .onClick(async ()=>{
              let dialog=new dialogInfo();
              let context = getContext(this) as common.UIAbilityContext
              let timestamp = new Date().getTime();
              dialog.file_path=context.filesDir+'/'+timestamp+'.wav'
              console.log(dialog.file_path)
              dialog.user_id=this.modelId
              dialog.userRequest=this.message
              this.audioList.push(dialog)
              this.getMessage()
              this.message=''
          })
      }
      .margin({bottom:20})
      .width('100%')
      .height('50')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}