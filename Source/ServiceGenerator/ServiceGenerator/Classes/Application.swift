//
//  Application.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//


import Foundation


/**
 ### Класс «Приложение»
 
 Предполагается, что в ходе исполнения код вспомогательного модуля **main.swift** запустит следующую
 инструкцию:
 ```
 exit(Application().run())
 ```
 - precondition: Для исполнения требует предоставить имена файлов заголовков модельных объектов в
 качестве параметров запуска.
 
 - postcondition: Результат исполнения: сгенерированы файлы заголовков и реализации парсеров,
 соответствующих предоставленным модельным объектам.
 - note: Заголовки модельных объектов должны быть соответствующим образом аннотированы.
 - seealso: main.swift
 */
class Application: ComposerApplication {

    override func printHelp() {
        super.printHelp()
        print("")
        print("-input_service <directory>")
        print("Path to the folder, where *.swift service files to be processed are stored.")
        print("If not set, current working directory is used by default.")
        print("")
        print("-input_model <directory>")
        print("Path to the folder, where *.swift model files to be processed are stored.")
        print("If not set, current working directory is used by default.")
        print("")
        print("-output_service <directory>")
        print("Path to the folder, where generated service files should be placed.")
        print("If not set, current working directory is used by default")
        print("")
        print("-output_model <directory>")
        print("Path to the folder, where generated model files should be placed.")
        print("If not set, current working directory is used by default")
        print("")
    }

    override func provideInputFoldersList(fromParameters parameters: ExecutionParameters) throws -> [String] {
        let serviceInputFolder: String = parameters["-input_service"] ?? "."
        let modelInputFolder:   String = parameters["-input_model"] ?? "."
        return [
            serviceInputFolder,
            modelInputFolder,
        ]
    }

    override func composeUtilities(forObjects objects: [Klass], parameters: ExecutionParameters) throws -> [Implementation] {
        let serviceOutputFolder: String = parameters["-output_service"] ?? "."
        let modelOutputFolder:   String = parameters["-output_model"] ?? "."

        let models: [Klass] = objects.filter { (item: Klass) -> Bool in return item.isModel() }
        let services: [Klass] = objects.filter { (item: Klass) -> Bool in return item.isService() }

        let serviceCallImplementations: [Implementation] = [
            ServiceCallComposer().composeUtilityImplementation(
                projectName: parameters.projectName,
                outputDirectory: modelOutputFolder
            ),
            AuthorizedServiceCallComposer().composeUtilityImplementation(
                projectName: parameters.projectName,
                outputDirectory: modelOutputFolder
            )
        ]

        let serviceDependencyImplementations: [Implementation] = [
            ServiceDependencyComposer().composeUtilityImplementation(
                projectName: parameters.projectName,
                outputDirectory: modelOutputFolder
            )
        ]

        let serviceLogFilterImplementations: [Implementation] = [
            ServiceLogFilterComposer().composeUtilityImplementation(
                projectName: parameters.projectName,
                outputDirectory: modelOutputFolder
            )
        ]

        let serviceComposer: ServiceComposer = ServiceComposer()
        let serviceImplementations: [Implementation] = try services.map { (service: Klass) -> Implementation in
            return try serviceComposer.composeEntityUtilityImplementation(
                forEntityKlass: service, availableEntityKlasses: models,
                projectName: parameters.projectName,
                outputDirectory: serviceOutputFolder
            )
        }

        return serviceCallImplementations + serviceDependencyImplementations + serviceLogFilterImplementations + serviceImplementations
    }

}
