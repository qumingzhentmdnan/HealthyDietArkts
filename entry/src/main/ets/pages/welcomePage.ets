import  Popup from '../view/agreementPopup'
import PreferenceUtil from '../common/utils/PreferenceUtil'
import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import axios from '@ohos/axios'


@Entry
@Component
struct WelcomePage {
  @State message: string = 'Hello World'
  url:string='http://192.168.73.99:8080'
  //获取context对象
  context = getContext(this) as common.UIAbilityContext

  //获取弹窗对象
  dialogController:CustomDialogController=new CustomDialogController({
    builder: Popup({
      //确认函数
      confirm: () => {
        //放入同意的key
        PreferenceUtil.putPreferenceValue('agreement', true)
        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/loginPage'
          })
        }, 1500)
      },

      //取消函数
      cancel: () => {
        //退出app
        this.context.terminateSelf()
      }
    }
    )
  })

  async isLogin(){
    let token=await PreferenceUtil.getPreferenceValue('token','')
    console.log('token'+token.toString())
    if(token){
      try {
        let url:string=this.url+'/user/isLogin'
        let res=await axios.get(url,{
          headers:{
            'token':token.toString()
          }
        })
        if(res.data.code==20000){
          router.replaceUrl({
            url:'pages/Index'
          })
          return
        }
        router.replaceUrl({
          url:'pages/loginPage'
        })
      }catch (Exception){
        console.log(Exception)
      }
    }
  }

  async  aboutToAppear(){
    let res=await PreferenceUtil.getPreferenceValue('agreement',false);
    console.log('res'+res.toString())
    if(res){
      console.log('res'+res.toString())
      setTimeout(async ()=>{
        await this.isLogin()
      },1500)
    }else{
      this.dialogController.open()
    }
  }


  build() {
    Column(){
      Image($r('app.media.log_img'))
        .width(150)
        .interpolation(1)
        .margin({top:150})
      Image($r('app.media.nameImg'))
        .width(200)
        .margin({top:50})
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.green'))
  }
}