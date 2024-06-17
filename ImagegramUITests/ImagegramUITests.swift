//
//  ImagegramUITests.swift
//  ImagegramUITests
//
//  Created by Владислав Усачев on 04.04.2024.
//

import XCTest
@testable import Imagegram


final class ImagegramUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        // Во время обычного теста вызывается метод fetchPhotosNextPage, который мешает тесту номер 2. Для этого блокируем вызов этого метода и запрашиваем только первые 10 фотографий.
        app.launchArguments = ["UITESTS"]
        app.launch()
    }
    
    override func tearDown() {
        // Очистка после каждого теста
        app = nil
        super.tearDown()
    }
    
   
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        //Нажмали на кнопку
        app.buttons["Authenticate"].tap()
        sleep(3)
        //Задали WebView и подождали загрузку
        let webView = app.webViews.element
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        //Задали textFiled и кнопку
        let webViewsQuery = app.webViews.webViews.webViews
        let emailAddressTextField = webViewsQuery/*@START_MENU_TOKEN@*/.textFields["Email address"]/*[[".otherElements[\"Connect Imagegram + Unsplash | Unsplash\"].textFields[\"Email address\"]",".textFields[\"Email address\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let passwordSecureTextField = webViewsQuery/*@START_MENU_TOKEN@*/.secureTextFields["Password"]/*[[".otherElements[\"Connect Imagegram + Unsplash | Unsplash\"].secureTextFields[\"Password\"]",".secureTextFields[\"Password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        //Ввели логин, пароль и нажмали вход
        XCTAssertTrue(emailAddressTextField.waitForExistence(timeout: 10))
        emailAddressTextField.tap()
        emailAddressTextField.typeText("usvladis@gmail.com")
        app.toolbars.buttons["Done"].tap()
        sleep(2)

        XCTAssertTrue(passwordSecureTextField.waitForExistence(timeout: 10))
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Adidasvlad20")
        app.toolbars.buttons["Done"].tap()
        sleep(2)
        
        
        webView.buttons["Login"].tap()
        
        //Задали tableView
        let photoFeedTable = app.tables
        let cell = photoFeedTable.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
        
    }
    
     
    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ожидание загрузки экрана ленты
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Скролл вверх по экрану
        app.swipeUp()
        sleep(2)
        
        // Скролл вниз по экрану
        app.swipeDown()
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
       
        // Проверить, что кнопка видима
        likeButton.tap()
        sleep(2)
        
        // Отменить лайк в ячейке верхней картинки
        likeButton.tap()
        sleep(2)
        
        // Нажать на верхнюю ячейку
        firstCell.tap()
        
        // Ожидание открытия картинки на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 2.0, velocity: 1.0)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1.0)
        
        // Вернуться на экран ленты
        app.buttons["BackButton"].tap()
        
        // Убедиться, что мы вернулись на экран ленты
        XCTAssert(firstCell.exists)
    }
    
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Подождать, пока открывается и загружается экран ленты
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["Vladislav Usachev"].exists)
        XCTAssertTrue(app.staticTexts["@usvladis"].exists)
        XCTAssertTrue(app.staticTexts["Люблю маму! "].exists)
        
        // Нажать кнопку логаута
        app.buttons["logoutButton"].tap()
        sleep(2)
        
        // Нажать кнопку "ОК" на алерте
        app.alerts["🚪"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)
        
        // Проверить, что открылся экран авторизации
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.exists)
        
    }

}
