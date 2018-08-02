//
//  APPublicIP
//
//  Copyright (c) 2015 Alban Perli - 2018 Flou Kévin.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public class APPublicIP {
    private func getDataFromUrl(urL:NSURL, completion: @escaping ((_ data: NSData?) -> Void)) {
        URLSession.shared.dataTask(with: urL as URL) { (data, response, error) in
            if(error != nil){
                print(error)
                completion(nil)
            }else{
                completion(data as! NSData)
            }
            }.resume()
    }
    
    private var previousIP : NSString!
    
    private var timer : Timer!
    
    
    public init(){
        previousIP = nil
        timer = nil
    }
    
    public func getCurrentIP(completion:@escaping ((_ ip : NSString?) -> Void)){
        if let checkedUrl = NSURL(string: "https://api.ipify.org?format=json") {
            getDataFromUrl(urL: checkedUrl, completion: { (data) -> Void in
                var parseError: NSError?
                do{
                let parsedObject: AnyObject? = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    if let jsonIP = parsedObject as? NSDictionary{
                        DispatchQueue.main.async() {
                            completion(jsonIP["ip"] as? NSString)
                        }
                    }
                }catch{
                    print("parseError")
                }
            })
        }
    }
    
    public func checkForCurrentIP(completion:@escaping ((_ ip : NSString?) -> Void), interval: TimeInterval){
        if self.timer != nil { self.stopChecking() }
        self.timer = Timer.new(every: interval) { () -> Void in
            self.getCurrentIP(completion: { (ip) -> Void in
                if (self.previousIP != nil){
                    if self.previousIP != ip {
                        self.previousIP = ip
                        completion(ip)
                    }
                }else{
                    self.previousIP = ip
                    completion(ip)
                }
            })
        }
        // Execute timer immediately (don't wait for first interval)
        self.timer.fire()

        // Start the timer
        self.timer.start()
    }


    public func stopChecking(){
        self.timer.invalidate()
        self.timer = nil
    }
}


