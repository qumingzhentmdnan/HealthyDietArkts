import router from '@ohos.router'
import simplePopup from '../view/simplePopup'
import check from '../function/infoCheck'
import {loginOrRegister, description} from '../common/component/Text'
import axios from '@ohos/axios'

@Entry
@Component
struct RegisterPage {
  @State phone:string=''
  @State password:string=''
  @State passwordVerify:string=''
  @State message:string=''
  @State code:string=''
  @State userInputCode:string=''
  @State userInputPhoneCode:string=''
  @State jump:boolean=false
  @State isRegister:boolean=false
  @State count:string='获取验证码'
  @State isCounting:boolean=false
  url:string='http://192.168.73.99:8080'

  checkPhone():boolean{
    if(!this.phone||!check.checkPhone(this.phone)){
      this.err('手机格式不正确')
      return false
    }
    return true
  }

  checkPassword():boolean{
    if(!this.password||!check.checkPassword(this.password)){
      this.err('请输入6-16数字字母组合密码')
      return false
    }
    return true
  }
  checkPasswordIsSame():boolean{
    if(!this.passwordVerify||!check.checkIsSame(this.password,this.passwordVerify)){
      this.err('两次密码不一致')
      return false
    }
    return true
  }
  checkCode():boolean{
    if(!this.code||!check.checkIsSame(this.code,this.userInputCode)){
      this.err('图形验证码错误')
      return false
    }
    return true
  }
  checkPhoneCode():boolean{
    if(!this.userInputPhoneCode||this.userInputPhoneCode.length!=4){
      this.err('手机验证码错误')
      return false
    }
    return true
  }
  checkAll(){
    if(!this.checkPhone()||!this.checkPassword()||!this.checkPasswordIsSame()||!this.checkCode()||!this.checkPhoneCode())
      return false
    return true
  }

  async getCode(){
      try {
        let res=await axios.get(this.url+'/user/getCode',{
          params:{
            phone:this.phone
          }
        })
        if(res.status==200){
          this.jump=false
          this.err(res.data.message)
        }
        if(res.data.code!=20000){
          return false
        }
        return true
      }catch (Exeption){
        console.log(Exeption)
      }
  }

  async register(){
    try {
      let path
      let method='post'
      if(this.isRegister){
        path=this.url+'/user/register'
      }else {
        path=this.url+'/user/updatePasswordByCode'
        method='put'
      }
      console.log(path)
      let res=await axios({
        url:path,
        method:method,
        data:{
          phone:this.phone,
          password:this.password,
          code:this.userInputPhoneCode,
        }
      })
      if(res.status===200){
        this.jump=false
        this.err(res.data.message)
      }
      if(res.data.code==20000){
        setTimeout(()=>{
          router.replaceUrl({
            url:'pages/loginPage'
          })
        },1000)
      }
    }catch (Exception){
      console.log(Exception)
    }
  }

  aboutToAppear(){
    this.code=((Math.random()*8999)+1000).toFixed(0).toString()
    this.isRegister=router.getParams()['isRegister']
    //this.isRegister=true
  }

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

  err:Function=(message:string)=>{
    this.message=message
    this.Popup()
  }

  build() {
      Column() {
          loginOrRegister({title:'登录'})
            .margin({ top: 20, right: 30,bottom:30 })
            .onClick(()=>{
              this.jump=true
              router.pushUrl({
                url:'pages/loginPage'
              })
            })

        if(this.isRegister){
          description({title:'创建健康饮食账号'})
            .margin({left:20,bottom:25})
        }else{
          description({title:'重置我的密码'})
            .margin({left:20,bottom:25})
        }

        Column({space:30}) {
          TextInput({placeholder:'请输入手机号',text:this.phone})
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .onChange((value)=>{
              this.phone=value
            })
            .onBlur(()=>{
              this.checkPhone()
            })

          TextInput({placeholder:'请输入6-16数字字母组合密码',text:this.password})
            .type(InputType.Password)
            .onChange(value=>{
              this.password=value
            })
            .onBlur(()=>{
              this.checkPassword()
            })

          TextInput({placeholder:'请再次确认输入密码',text:this.passwordVerify})
            .type(InputType.Password)
            .onChange(value=>{
              this.passwordVerify=value
            })
            .onBlur(()=>{
              this.checkPasswordIsSame()
            })

          Row(){
            TextInput({placeholder:'请输入图形验证码',text:this.userInputCode})
              .type(InputType.Number)
              .maxLength(4)
              .width('70%')
              .onChange(value=>{
                this.userInputCode=value
              })
              .onBlur(()=>{
               this.checkCode()
              })

            Text(this.code)
              .borderWidth(1)
              .width('30%')
              .borderRadius(10)
              .fontSize(25)
              .backgroundColor(Color.Gray)
              .textAlign(TextAlign.Center)
              .onClick(()=>{
                this.code=((Math.random()*8999)+1000).toFixed(0).toString()
              })
          }

         Row(){
           TextInput({placeholder:'请输入手机验证码',text:this.userInputPhoneCode})
             .type(InputType.Number)
             .textAlign(TextAlign.Start)
             .width('70%')
             .onChange(value=>{
               this.userInputPhoneCode=value
             })
             .onBlur(()=>{
              this.checkPhoneCode()
             })
           Button(this.count)
             .width('30%')
             .fontSize(13)
             .onClick(async ()=>{
               if(!this.checkPhone())
                 return
               if(this.isCounting){
                 this.message='验证码已发送'
                 this.Popup()
                 return
               }
              if(!await this.getCode())
                return
               for(let i=120;i>=0;i--){
                 setTimeout(()=>{
                   console.log(i.toString())
                   this.count=i.toString();
                 },(120 - i )* 1000)
               }
               setTimeout(()=>{
                 this.isCounting=true
                 this.count='获取验证码'
               },120*1000)
             })
         }

          if(this.isRegister){
             Button('注册')
              .width('80%')
              .onClick(()=>{
                if(this.checkAll())
                  this.register()
              })
          }else{
            Button('重置')
              .width('80%')
              .onClick(()=>{
              if(this.checkAll()){
                console.log("进入check")
                this.register()
              }
            })
          }

        }.width('90%')
      }
      .width('100%')
  }
}