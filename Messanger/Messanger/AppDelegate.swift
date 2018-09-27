//
//  AppDelegate.swift
//  Messanger
//
//  Created by Nikhil on 9/25/18.
//

import UIKit
import XMPPFramework

protocol ChatDelegate {
    func buddyWentOnline(name: String)
    func buddyWentOffline(name: String)
    func didDisconnect()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPRosterDelegate, XMPPStreamDelegate {
    
    var window: UIWindow?
    var delegate:ChatDelegate! = nil
    var xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster
    
    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DDLog.add(DDTTYLogger.sharedInstance)
        
        setupStream()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        disconnect()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication){
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let _ = connect()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Private Methods
    private func setupStream() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        
        xmppStream.hostName = "Nikhils-MacBook-Pro.local";
        xmppStream.hostPort = 5222
        
        xmppRoster.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    private func goOnline() {
        let presence = XMPPPresence()
        _ = xmppStream.myJID?.domain
        
        let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
            presence.addChild(priority)
        xmppStream.send(presence)
    }
    
    private func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
    }
    
    func connect() -> Bool {
        if !xmppStream.isConnected {
            let jabberID = "admin@localhost"
            let myPassword = "12345"
            
            if !xmppStream.isDisconnected {
                return true
            }
            if jabberID.count == 0 && myPassword.count == 0 {
                return false
            }
            
            xmppStream.myJID = XMPPJID(string: jabberID)
            xmppStream.hostName = "Nikhils-MacBook-Pro.local";
            xmppStream.hostPort = 5222
            
            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
    }
    
    //MARK: XMPP Delegates
    func xmppStreamDidConnect(sender: XMPPStream!) {
        do {
            try    xmppStream.authenticate(withPassword: "12345")
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        print("Did receive message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("Did send message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type
        let myUsername = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(String(describing: presenceFromUser))")
            if presenceType == "available" {
                delegate.buddyWentOnline(name: "\(String(describing: presenceFromUser))@gmail.com")
            } else if presenceType == "unavailable" {
                delegate.buddyWentOffline(name: "\(String(describing: presenceFromUser))@gmail.com")
            }
        }
    }
    
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        print("Did receive Roster item")
    }
}

