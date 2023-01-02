import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:token_erc_20/widgets/dialog_loading.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BigInt? usdcBalance = BigInt.from(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USDC Balance"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${usdcBalance ?? 0} USDC",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _onGetTokenBalance,
              child: const Text("Get Balance"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGetTokenBalance() async {
    // show loading
    DialogLoading.loadingWithText(context);

    // get deployed contract
    final DeployedContract contract = await _onGetContract();

    // get token balance
    final BigInt balance = await _onGetBalance(deployedContract: contract);

    // close loading
    Navigator.pop(context);

    // set usdc balance
    setState(() {
      usdcBalance = balance;
    });
  }

  Future<DeployedContract> _onGetContract() async {
    // load contract from local
    final String fileAbi =
        await rootBundle.loadString("assets/contracts/TokenBalance.json");
    
    const String contractName = "balanceOf";
    // USDC goerli ethereum smart contract address
    const String tokenContractAddress =
        "0x07865c6E87B9F70255377e024ace6630C1Eaa37F";

    // get deployed contract
    final DeployedContract deployedContract = DeployedContract(
      ContractAbi.fromJson(fileAbi, contractName),
      EthereumAddress.fromHex(tokenContractAddress),
    );

    return deployedContract;
  }

  Future<BigInt> _onGetBalance({
    required DeployedContract deployedContract,
  }) async {
    // the goerli wallet address which will be used
    const String walletAddress = "0x4994986400D969EeA1f90bE393A5F1B1b72a664A";
    // goerli infura API URl
    const String goerliInfuraApiUrl = "https://goerli.infura.io/v3";
    // goerli infura API Key
    const String goerliInfuraApiKey = "API_KEY";
    // get balance function name in smart contract
    const String functionName = "balanceOf";

    // http client
    final Client httpClient = Client();
    // complete client url
    const String url = "$goerliInfuraApiUrl/$goerliInfuraApiKey";
    // web3dart object
    final Web3Client web3client = Web3Client(url, httpClient);

    // call contract
    final List<dynamic> result = await web3client.call(
      contract: deployedContract,
      function: deployedContract.function(functionName),
      params: [
        // wallet address
        EthereumAddress.fromHex(walletAddress),
      ],
    );

    return result[0];
  }
}
