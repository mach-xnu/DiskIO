import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            DiskIOView()
                .edgesIgnoringSafeArea(.all)
                
                .background(Color(red: 38/255, green: 0/255, blue: 77/255))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
