import simplePopup from '../view/simplePopup'

class infoCheck{
    checkPhone(phone:string){
      if(!phone)
        return
      let regex=new RegExp('^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\\d{8}$')
      let res=regex.test(phone)
      console.log('日志'+res.toString())
      return res;
    }

    checkPassword(password:string){
      if(!password)
        return false
      let regex=new RegExp('^[a-zA-Z0-9]{6,16}$')
      let res=regex.test(password)
      return res
    }

    checkIsSame(str1:string,str2:string,errMessage?:string){
      if(!(str1&&str2))
        return
      let res=str1===str2
      return res
    }
}

let Check=new infoCheck();
export default Check