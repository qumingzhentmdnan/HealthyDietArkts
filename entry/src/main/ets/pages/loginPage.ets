import simplePopup from '../view/simplePopup'
import check from '../function/infoCheck'
import router from '@ohos.router'
import axios from  '@ohos/axios'
import PreferenceUtil from  '../common/utils/PreferenceUtil'

@Entry
@Component
struct LoginPage {
  @State phone:string=''
  @State password:string=''
  @State message:string=''
  @State jump:boolean=false
  //使用localhost模拟器无法发送请求
  url:string='http://192.168.73.99:8080'

  dialogController: CustomDialogController = new CustomDialogController({
    builder: simplePopup({message:this.message}),
    customStyle:true,
  })

  Popup:Function=()=>{
    //防止点击跳转按钮导致失去焦点弹出信息
    if(this.jump){
      this.jump=false
      return
    }
    this.dialogController.open()
    //弹出窗口会导致失去焦点，修改为true，防止再弹出一次
    this.jump=true
    setTimeout(()=>{
      this.dialogController.close()
    },1500)
  }

  async login(){
    try {
      let res=await axios({
        url:this.url+'/user/login',
        method: 'post',
        data:{
          phone:this.phone,
          password:this.password
        }
      })
      if(res.status===200){
        this.jump=false
        this.message=res.data.message
        this.Popup()
      }
      if(res.data.code==20000){
        await PreferenceUtil.putPreferenceValue('token',res.data.data.token)
        await PreferenceUtil.putPreferenceValue('phone',this.phone)
        setTimeout(()=>{
          router.replaceUrl({
            url:'pages/Index'
          })
        },1000)
      }else{
        this.message=res.data.message
        this.Popup()
      }
    } catch (exception) {
      console.log(exception)
    }
  }

  async aboutToAppear(){
    let res=await PreferenceUtil.getPreferenceValue('phone','')
    this.phone=res.toString()
  }


  build() {
    Column() {
      Text('注册')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.End)
        .fontColor(Color.Blue)
        .width('100%')
        .margin({ top: 20, right: 30,bottom:30 })
        .onClick(()=>{
          this.jump=true
          router.pushUrl({
            url:'pages/registerPage',
            params:{
              isRegister:true
            }
          })
        })

      Row({ space: 10 }) {
        Image($r('app.media.log_img'))
          .width(40)
          .borderRadius(10)
        Text('健康饮食')
          .fontSize(20)
          .fontWeight(FontWeight.Bolder)
      }
      .width('90%')
      .justifyContent(FlexAlign.Start)
      .margin({bottom:50})

      Column({space:30}) {
        TextInput({placeholder:'请输入手机号',text:this.phone})
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .onChange((value)=>{
            this.phone=value
          })
          .onBlur(()=>{
            if(!check.checkPhone(this.phone)){
              console.log('phone'+this.phone)
              this.message='手机格式不正确'
              this.Popup()
            }
          })

       TextInput({placeholder:'请输入密码',text:this.password})
         .type(InputType.Password)
         .onChange((value)=>{
           this.password=value
         })
      }.width('90%')
      Text('忘记了？找回密码')
        .width('85%')
        .fontSize(10)
        .fontColor(Color.Blue)
        .margin({top:10,bottom:75})
        .onClick(()=>{
          this.jump=true
          router.pushUrl({
            url:'pages/registerPage',
            params:{
              isRegister:false
            }
          })
        })
      Button('登录')
        .width('80%')
        .onClick(()=>{
          if(this.phone==null||this.password==null){
            this.message='手机号或者密码不能为空'
            this.Popup()
          }
          this.login()
        })
    }
    .width('100%')
  }
}























