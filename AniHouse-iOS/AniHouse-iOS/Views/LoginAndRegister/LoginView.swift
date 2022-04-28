//
//  LoginView.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/03/24.
//

import SwiftUI
import Lottie

struct LoginView: View {
    @State var userId: String = ""
    @State var userPassword: String = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                Text("You are signed In!")
                // 이미 로그인 한 유저의 경우 이곳을 통해 홈 뷰로 이동.
                
                
            }
            else {
                SignInView()
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
